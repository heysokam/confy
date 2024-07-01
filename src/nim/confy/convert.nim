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
import ./convert/tools

#_______________________________________
# Forward Export the requirements for the external API
export make.MakeInput
export make.MakeInputs


#_______________________________________
# @section Entry Point: Make Converter
#_____________________________
proc fromMake *(
    targets     : MakeInputs;
    tempDir     : Path;
    targetsDir  : Path;
    renameCB    : RenameFunc       = RenameFunc_default;
    postprocess : PostProccessFunc = nil;
    headerTempl : static string    = "";
    strip       : static string    = "";
    unified     : bool             = true;
    connector   : bool             = true;
    force       : bool             = false;
  ) :void=
  ## @descr Generates a confy buildsystem equivalent for the given list of {@arg MakeInput}s
  ##
  ## @arg headerTempl  User defined text (or code) that will be added at the top of each file.
  ## @arg unified      If true, when a single make keyword builds multiple targets, its targets will all be generated into the same file.
  ##                   Otherwise they will be each on their own separate file.
  ## @arg connector    If true, a connector module will be generated for ergonomic access to all generated {@link BuildTrg} code
  ## @arg force        If true, the code will be regenerated and/or overwritten without consideration of whether it already exists or not.
  var makelists :MakeLists
  # Read/Write the Make commands
  if force or not make.parse.generated(targets, at=tempDir):  # Generate the Make commands lists if the dir doesn't exist, or force is active
    if force: reportForcedWarning()
    echo &"Generating temporary makelist targets at:  {tempDir}"
    makelists = make.parse.getMakeLists(targets, renameCB)
    makelists.writeFiles(tempDir)
  else:  # Get the Make commands lists from the generated sh files without rebuilding them when they already exist
    echo &"Note: Remove the tempDir folder, or activate force mode, to regenerate the temporary makelist targets at:  {tempDir}"
    makelists = make.parse.readMakeLists(targets, tempDir, renameCB)

  # Convert the Make commands into confy
  var codegens = make.parse.filter.toCodegenLists(makelists)
  let files = make.codegen.writeFiles(codegens, targetsDir, headerTempl, strip, unified, connector, force)

  # Apply the postprocess function to all generated files
  if postprocess != nil:
    for file in files:
      if not file.endsWith(".nim") or not fileExists(file): continue
      echo &"Applying postprocess function to:  {file}"
      file.writeFile( file.readFile.postprocess() )

