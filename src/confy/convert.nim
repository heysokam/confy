#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @fileoverview External API for all of the confy.convert modules
#_________________________________________________________________|
# @deps ndk
import nstd/strings
import nstd/paths
# @deps confy.convert
import ./convert/make

#_______________________________________
# Forward Export the requirements for the external API
export make.MakeInputs


#_______________________________________
# @section Entry Point: Make Converter
#_____________________________
proc fromMake *(
    targets    : MakeInputs;
    tempDir    : Path;
    targetsDir : Path;
    renameCB   : RenameFunc = RenameFunc_default;
  ) :void=
  var makelists :MakeLists
  # Read/Write the Make commands
  if not make.parse.generated(targets, at=tempDir):  # Generate the Make commands lists if the dir doesn't exist
    makelists = make.parse.getMakeLists(targets, renameCB)
    makelists.writeFiles(tempDir)
  else:  # Get the Make commands lists from the generated sh files without rebuilding them when they already exist
    echo &"Note: Remove the targetsDir folder to regenerate the make output files at:  {tempDir}"
    makelists = make.parse.readMakeLists(targets, tempDir, renameCB)

  # Convert the Make commands into confy
  var codegens = make.parse.filter.toCodegenLists(makelists)
  make.codegen.writeFiles(codegens, targetsDir)

