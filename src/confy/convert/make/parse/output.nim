#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/osproc import execCmdEx
# @deps ndk
import nstd/strings
import nstd/paths
import nstd/shell
# @deps make.parse
import ../types
import ./checks


#_______________________________________
# @section Clean Make's Output
#_____________________________
proc condenseNewlines (input :string) :string=
  ## @descr Fixes any \ newlines contained in the {@arg input}
  var nextAdd  :bool
  for line in input.splitLines():
    let first = line.strip().split(' ', 1)[0] # First word of the line
    if not first.isKnown():
      writeFile( getAppDir()/"broken.sh", input )
      assert false, &"Found a line that contains a first word that is not recognized:\n  {first}\n{line}"
  for line in input.splitLines():
    if line.endsWith("\\"):
      result.add line[0..^2] # Remove the last character
      nextAdd = true
      continue  # skip adding "\n" at the end of the loop
    elif nextAdd:
      result.add line
      nextAdd = false
    else: result.add line
    result.add "\n"
#___________________
proc clean (input :string; dir=Path""; name="") :string=
  ## @descr Cleans the input block of commands by splitting all lines and filtering out everything that shouldn't reach the parser.
  if name != "": echo &"Cleaning:  {dir.lastPathPart()/name}\n"
  for line in input.condenseNewlines.split("\n"):
    let first = line.strip.split(' ', 1)[0] # First word of the line
    if   not first.isKnown: echo &"\nWRN:: Found a line that contains a first word that is not recognized:\n  {first}\n{line}"
    elif not first.isCmd: continue
    result.add line & "\n"


#_______________________________________
# @section Get Make's Output
#_____________________________
proc getMakeList *(
    input    : MakeInput;
    renameCB : RenameFunc = RenameFunc_default;
  ) :MakeList=
  ## @descr Generates a list of make commands from the given make input.
  let make = &"make -j8 --output-sync {input.key} -n"
  echo &"Running:  {make}"
  let cmd  = &"cd {input.root} ; {make}"
  result.name = renameCB(input.name)  # Identifiable name for the list
  result.file = input.name.Path       # Basename of the temporary file, before the input.name is renamed
  result.key  = input.key             # Keyword used to get the data
  result.root = input.root            # Folder where the codegen result will be output
  result.dir  = input.dir             # Folder where the conversion result should be output
  when nimvm : result.res = gorgeEx( cmd ).output.clean( input.dir, input.name ).splitLines()
  else       : result.res = execCmdEx( cmd ).output.clean( input.dir, input.name ).splitLines()
#___________________
proc getMakeLists *(
    trgs     : MakeInputs;
    renameCB : RenameFunc = RenameFunc_default;
  ) :MakeLists=
  ## @descr
  ##  Generates a list of make commands for each of the given make inputs.
  ##  Renames the final `list.name` using the given {@arg renameCB} function
  for trg in trgs: result.add trg.getMakeList(renameCB)


#_______________________________________
# @section Write Make output to files
#_____________________________
proc writeFile *(list :MakeList; trgDir :Path) :void=
  ## @descr Writes the given {@arg list} object to a file inside {@arg trgDir}
  echo "Writing MakeList file for:  ",list.dir/list.name
  let dir = trgDir/list.dir.lastPathPart()
  if not dirExists(dir): md dir
  let file = (dir/list.file).addFileExt(".sh")
  file.writeFile( list.res.join("\n") )
#___________________
proc writeFiles *(makelist :MakeLists; trgDir :Path) :void=
  ## @descr Writes the given {@arg makelist} objects to files inside {@arg trgDir}
  for list in makelist:  list.writeFile( trgDir )


#_______________________________________
# @section Read Make output from generated sh files
#_____________________________
proc readMakeList *(
    input    : MakeInput;
    trgDir   : Path;
    renameCB : RenameFunc = RenameFunc_default;
  ) :MakeList=
  ## @descr
  ##  Reads the Make {@arg input} from {@trgDir}, and returns a {@link MakeList} object
  ##  Used to not need to call for Make multiple times, which can be really slow
  ##  Renames the final `list.name` using the given {@arg renameCB} function
  let dir  = trgDir/input.dir.lastPathPart()
  let file = (dir/input.name).addFileExt(".sh")
  echo "Reading:  ",file
  result.name = renameCB(input.name)  # Identifiable name for the list
  result.file = input.name.Path       # Basename of the temporary file, before the input.name is renamed
  result.key  = input.key             # Keyword used to get the data
  result.root = input.root            # Folder where the codegen result will be output
  result.dir  = input.dir             # Folder where the conversion result should be output
  result.res  = file.readFile.splitLines()
#___________________
proc readMakeLists *(
    inputs   : MakeInputs;
    trgDir   : Path;
    renameCB : RenameFunc = RenameFunc_default;
  ) :MakeLists=
  ## @descr
  ##  Reads the Make {@arg inputs} list from {@trgDir}, and returns a list of {@link MakeList} objects
  ##  Used to not need to call for Make multiple times, which can be really slow
  ##  Renames the final `list.name` using the given {@arg renameCB} function
  for input in inputs: result.add input.readMakeList( trgDir, renameCB )

