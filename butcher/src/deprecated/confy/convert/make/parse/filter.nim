#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/tables import hasKey, `[]=`, `[]`, contains
from std/sequtils import anyIt, filterIt, mapIt, toSeq
# @deps ndk
import nstd/sets
import nstd/strings
import nstd/paths
import confy
# @deps make.parse
import ../types
import ./checks


#_______________________________________
# @section Error Management
#_____________________________
const echo = debugEcho
type FilterError = object of CatchableError
proc triggerIf (err :typedesc[CatchableError]; cond :bool; msg :string) :void=
  if cond: raise newException(err, msg)


#_______________________________________
# @section IR objects Generation Tools
#_____________________________
func getList (list :string) :seq[string]= list.split(",").mapIt( it.strip )
  ## @descr Returns a list of strings from the {@arg list}
#___________________
func toMode *(trg :string) :BuildMode=
  ## @descr
  ##  Returns the buildmode of {@arg trg}
  ##  It will be Release if the path contains the `release` keyword in it
  if "release" in trg: Release else: Debug
#___________________
const KnownOS {.strdefine.}= "win32, mingw32, mingw64, windows, linux, macos, macosx, darwin"
proc toOS *(os  :string) :OS=
  ## @warning
  ##  This function is very likely to fail in any buildsystem other that the Quake3Arena Buildsystem
  ##  It relies on the Quake3Arena buildsystem naming convention for determining the OS compilation target
  ##  Please override it with your own {@link ToOSFunc} if this condition is not true for your target Makefile naming convention
  let known = KnownOS.getList()
  assert os in known, &"Found an unmapped Operating System in the default `toOS` function:\n  Known list: {KnownOS}\n  {os}"
  case os
  of "win32", "mingw32", "mingw64" : return Windows
  of "darwin"                      : return Mac
  else : return parseEnum[OS](os)
#___________________
const KnownCPU {.strdefine.}= "x86_64, amd64, aarch64, arm64, arm, x86"
proc toCPU *(cpu :string) :CPU=
  ## @warning
  ##  This function is very likely to fail in any buildsystem other that the Quake3Arena Buildsystem
  ##  It relies on the Quake3Arena buildsystem naming convention for determining the CPU compilation target
  ##  Please override it with your own {@link ToCPUFunc} if this condition is not true for your target Makefile naming convention
  let known = KnownCPU.getList()
  assert cpu in known, &"Found an unmapped CPU Architecture in the default `toCPU` function:\n  Known list: {KnownCPU}\n  {cpu}"
  case cpu
  of "x86_64"  : x86_64
  of "aarch64" : arm64
  else         : return parseEnum[CPU](cpu)
#___________________
proc getSystem *(
    trg    : Path;
    getOS  : ToOSFunc;
    getCPU : ToCPUFunc;
  ) :System=
  ## @descr Returns the System that this {@arg trg} is going to be built for
  ##
  ## @warning
  ##  This function is very likely to fail in any buildsystem other that the Quake3Arena Buildsystem
  ##  It relies on the `release` or `debug` keywords being part of the {@arg trg} path to determine whether the word should be skipped or not
  #   It also relies on words being separated by `-`
  ##  Which means that it will skip everything, and output an empty system, when those words are not part of the {@arg trg} path
  ##
  ##  Example: "release-OS-CPU"
  ##  Please override this function with your own {@link GetSystemFunc} if this condition is not true for your target Makefile naming convention
  for word in trg.string.split(DirSep):
    if not ("release" in word or "debug" in word): continue
    let split  = word.split("-")
    result.os  = split[1].getOS
    result.cpu = split[2].getCPU


#_______________________________________
# @descr Temporary Code objects for IR generation
#_____________________________
const SkipAssembler = ["-x", "assembler-with-cpp"]
func toCodeFiles (src :OrderedSet[Path]; flags :OrderedSet[string]; assembler :bool= false) :OrderedSet[CodeFile]=
  ## @descr Converts the given src list into a CodeFile list, where all entries are given the input flags.
  for file in src: result.incl CodeFile(file:file, flags: if assembler: flags else: flags.toSeq.filterIt( it notin SkipAssembler ).toOrderedSet())
#___________________
func getCodeFiles *(trg :RootTarget; assembler :bool= false) :OrderedSet[CodeFile]=
  ## @descr
  ##  Returns a list of code files used to build this target.
  ##  They are turned absolute based on the rootDir stored in {@arg trg}: `trg.root/file`
  ##  @note The root folder is where the makefile lives.
  # Direct case, without intermediate obj passes
  if trg.isDirect(): return trg.src.toCodeFiles(trg.flags, assembler)
  # Normal case, where files are first compiled with `-c` and then linked from `.o`
  for ctrg in trg.deps:  # For every dependency
    result = result + ctrg.src.toCodeFiles(ctrg.flags, assembler)  # Get the source code of the dependency
#_____________________________
func toCodeFolders (src :OrderedSet[Path]) :Hashset[Path]=
  ## Returns a list of unique folders where all of the files in the list are contained.
  for file in src: result.incl( file.splitFile.dir )
#___________________
func toCodeFolders (deps :OrderedSet[CTarget]) :Hashset[Path]=
  ## Returns a list of unique folders where all of the files from the list of targets are contained.
  for trg in deps:
    for file in trg.src: result.incl( file.splitFile().dir )
#___________________
func getCodeFolders *(trg :RootTarget) :Hashset[Path]=
  ## @descr Returns the list of folders where the code for {@arg trg} is contained.
  # Direct case, without intermediate obj passes
  if trg.isDirect(): return trg.src.toCodeFolders()
  # Normal case, where files are first compiled with `-c` and then linked from `.o`
  trg.deps.toCodeFolders()


#_______________________________________
# @descr Generate the Temporary IR objects
#_____________________________
func getKind *(words :seq[string]) :BinKind=
  ## @descr Finds the type of Compilation output that this target creates.
  if   words.isObj       : return Object
  elif words.isDynLib    : return SharedLibrary
  elif words.isStaticLib : return StaticLibrary
  elif words.isApp       : return Program
#___________________
func getCC *(words :seq[string]) :string=
  ## @descr Finds the compiler command, which must always be the first word of the line:(seq[word])
  result = if words.len == 0: "" else: words[0]
#___________________
const LangSwitches = ["assembler-with-cpp"]
#___________________
func getSrc *(line :seq[string]) :OrderedSet[Path]=
  ## @descr Finds the source code files that are used on the given Make {@arg line}.
  var output :string
  for id,word in line.pairs:                                   # For every word in this line
    if   id == 0              : continue                       # First word is always the tool command
    elif word == "-o"         : output = line[id+1]; continue  # Binary output is always the next word after `-o`
    elif word.startsWith("-") : continue                       # Switches are not source code
    elif word == output       : continue                       # Binary output is not source code
    elif word in LangSwitches : continue                       # Language switches for `-x<lang>` are not source code
    result.incl word.Path                                      # Otherwise we found a source code file
#___________________
func getFlags *(line :seq[string]) :OrderedSet[string]=
  FilterError.triggerIf line.anyIt( it == "-S" or it == "-E"),
    "Assembler and Preprocessor only steps are not supported."
  for flag in line.filterIt( it.isFlag() ): result.incl flag
#___________________
func getCTarget *(line :seq[string]) :CTarget=
  result = CTarget(
    kind  : line.getKind(),
    trg   : line.getTrg(),
    cc    : line.getCC(),
    src   : line.getSrc(),
    flags : line.getFlags(),
    ) # << CTarget( ... )
#___________________
func findNonRoots (list :MakeList) :CTargets=
  ## @descr Find the list of {@link CTargets} described by the given {@arg list}
  echo &"\tFinding Non-Root targets for  {list.name}"
  for mkline in list.res:
    let line = mkline.splitWhitespace()
    if line.isRoot(): continue
    assert line != @[] and line.anyIt(it != "")
    result.add line.getCTarget()
#___________________
proc getRootTarget *(dep :CTarget; rootDir :Path) :RootTarget=
  ## @descr Find the Root Target that this CTarget defines
  result = RootTarget(
    kind  : dep.kind,
    trg   : dep.trg,
    cc    : dep.cc,
    root  : rootDir,
    src   : dep.src,
    deps  : initOrderedSet[CTarget](), # RootTargets do not have dependencies
    flags : dep.flags,
    ) # << RootTarget( ... )
#___________________
func getRootTarget (line :seq[string]; rootDir :Path) :RootTarget=
  result = RootTarget(
    kind  : line.getKind(),
    trg   : line.getTrg(),
    cc    : line.getCC(),
    root  : rootDir,
    src   : line.getSrc(),
    deps  : initOrderedSet[CTarget](), # RootTargets do not have dependencies
    flags : line.getFlags(),
    ) # << RootTarget( ... )
#___________________
func findRoots *(
    list     : MakeList;
    nonroots : CTargets;
    rootDir  : Path;
  ) :RootTargets=
  ## @descr Find the list of {@link RootTargets} described by the given {@arg list}, based on the given list of {@arg nonroots}
  echo &"\tFinding Root targets for  {list.name}  from  {rootDir}"
  # 1. Find the RootTarget of the MakeList
  for mkline in list.res:
    if mkline == "": continue               # Skip empty lines
    let line = mkline.splitWhitespace()     # Divide the line into words
    if not line.isRoot(): continue          # Skip lines that describe a non-root step
    result.add line.getRootTarget(rootDir)  # Find the Root Target that this line defines
  # 2. Search each target, comparing each line with its obj list
  for root in result.mitems:
    for trg in nonroots:                          # For every dependency of the RootTarget
      if trg.trg in root.src: root.deps.incl trg  # Add input file to the resulting code list if there is a match


#_______________________________________
# @descr Generate the FinalTargets IR objects
#_____________________________
proc toSplitTarget (trg :Path) :tuple[bin:Path, binDir:Path, subDir:Path]=
  let file = trg.string.split(DirSep)
  assert file.len in {3,4}, &"Tried to use the default `toSplitTarget` function on a path, but its format is incorrect. It should have a length of 3 or 4, but is {file.len} instead:\n  {trg}"
  result.binDir = file[0].Path
  result.subDir = file[1..^2].join($DirSep).Path
  result.bin    = file[^1].Path
#___________________
proc toFinal (
    root        : RootTarget;
    getMode     : GetModeFunc     = nil;
    getSyst     : GetSystemFunc   = nil;
    getOS       : ToOSFunc        = nil;
    getCPU      : ToCPUFunc       = nil;
    splitTarget : SplitTargetFunc = nil;
    pattern     : string          = ".c";
    assembler   : bool            = false;
  ) :FinalTarget=
  # Error check and report to CLI
  assert root.trg != "".Path
  echo &"\tFinding Final Targets for {root.trg}"

  # Store the initial data
  result = FinalTarget(
    bin     : root.trg.lastPathPart,
    mode    : if getMode.isNil: filter.toMode(root.trg.string) else: getMode(root.trg.string),
    kind    : root.kind,
    system  : # Get the system from the callbacks (selected by whether they are `nil` or not)
      if getSyst.isNil : filter.getSystem(root.trg, filter.toOS, filter.toCPU)
      else             : getSyst(root.trg,
        if  getOS.isNil: filter.toOS  else: getOS,
        if getCPU.isNil: filter.toCPU else: getCPU
        ), # << getSyst(root.trg, ... )
    deps    : newSeq[CodeFile](), # Empty deps list
    src     : newSeq[CodeFile](), # Empty src list
    globs   : newSeq[CodeDir](),  # Empty glob
    excepts : newSeq[CodeDir](),  # Empty excepts
    lflags  : root.flags,
    ) # << FinalTarget( ... )
  (result.bin, result.binDir, result.subDir) = if splitTarget.isNil: filter.toSplitTarget(root.trg) else: splitTarget(root.trg)

  # Add assembler dependencies to the list of explicit deps files of the FinalTarget
  for dep in root.deps:
    if not dep.flags.toSeq.isAssembler(): continue
    result.deps.add CodeFile(file: dep.trg, flags: dep.flags)

  # Assembler targets should get their source code list fully explicit
  if assembler:
    for file in root.src:
      result.src.add CodeFile(file: file, flags: root.flags)

  # Override `.o` files from mingw
  if result.system.os == Windows:
    if result.kind == Object: result.bin = result.bin.changeFileExt(".obj")
    for src in result.src.mitems:
      if src.file.endsWith(".o"): src.file = src.file.changeFileExt(".obj")
    for dep in result.deps.mitems:
      if dep.file.endsWith(".o"): dep.file = dep.file.changeFileExt(".obj")

  # Create the list of Excepts   (note: just gets the data from one object to the other, no fancy logic)
  # 1.0 Skip searching globs+excepts for assembler targets
  if assembler: return
  # 1.1 Find the code files
  let sources = root.getCodeFiles()
  FilterError.triggerIf sources.len == sources.type.default().len,
    &"root.getCodeFiles() failed for {root.trg}. It should never return an empty object. Its root data is:\n{root}"
  # 1.2 Find the code folders
  # 1.2.1 Find the folders
  let folders = root.getCodeFolders()
  FilterError.triggerIf folders.len == folders.type.default().len,
    &"root.getCodeFolders() failed for {root.trg}. It should never return an empty object. Its root data is:\n{root}"
  # 1.2.2 Populate the exceptions list for each folder  (easier to filter out)
  var excepts :CodeSet  # List of folders with exceptions, and their contents
  for folder in folders:
    echo &"\t\tPopulating exceptions from real files at  {root.root/folder}"
    for realfile in (root.root/folder).globDir():
      if realfile notin sources:
        echo &"\t\t\tException file found:  {realfile}"
        if not excepts.hasKey(folder): excepts[folder] = initHashset[Path]()
        excepts[folder].incl realfile.relativePath(root.root)

  # 1.3 Find globs+excepts
  for folder in folders:
    echo &"\t\tAdding glob folder:  {root.root/folder}"
    # 1.3.1 Find the flags for this folder
    var dirCflags :OrderedSet[string]             # List of cflags for this folder
    for file in sources:
      dirCflags += file.flags  # Join the list of flags for all files into the resulting list of flags for the folder
    # 1.3.2. Create the list of globs  ( Only folders that can be fully globbed are on this list )
    if folder notin excepts:
      result.globs.add CodeDir(kind:Glob,
        dir     : folder,
        pattern : pattern,
        cflags  : dirCflags,
        ) # << CodeDir( ... )
    # 1.3.3. Create the list of resulting excepts filters
    elif folder in excepts:  # Store folders for which exceptions were found (aka compileDir(filters = ...)
      echo &"\t\tAdding exception files for folder {root.root/folder}"
      result.excepts.add CodeDir(kind:Excp,
        dir     : folder,
        pattern : pattern,
        cflags  : dirCflags,
        filters : excepts[folder], # Get the exceptions contents of this folder from the excp list
        ) # << CodeDir( ... )
#___________________
proc toFinals (
    roots       : RootTargets;
    getMode     : GetModeFunc     = nil;
    getSyst     : GetSystemFunc   = nil;
    getOS       : ToOSFunc        = nil;
    getCPU      : ToCPUFunc       = nil;
    splitTarget : SplitTargetFunc = nil;
    pattern     : string          = ".c";
  ) :FinalTargets=
  ## @descr
  ##  Creates a {@link FinalTarget} from the input {@arg list} of RootTarget
  ##  It will use {@arg getSystem} function to determine the system that the target of each line is being built for
  ##  Files will be searched for assuming they contain {@arg pattern} in their name
  ##  Dependencies will be searched for independently of {@arg pattern}
  for trg in roots:
    for dep in trg.deps:
      if not dep.isAssembler(): continue
      result.add dep.getRootTarget(trg.root).toFinal(getMode, getSyst, getOS, getCPU, splitTarget, pattern = ".s", assembler=true)
    result.add trg.toFinal(getMode, getSyst, getOS, getCPU, splitTarget, pattern)
#___________________
proc toFinalTargets *(
    list        : MakeList;
    rootDir     : Path;
    getMode     : GetModeFunc     = nil;
    getSyst     : GetSystemFunc   = nil;
    getOS       : ToOSFunc        = nil;
    getCPU      : ToCPUFunc       = nil;
    splitTarget : SplitTargetFunc = nil;
    pattern     : string          = ".c";
  ) :FinalTargets=
  ## @descr
  ##  Creates a list of {@link FinalTarget} from the input {@arg list} of Make commands, relative to {@arg rootDir}
  ##  It will use {@arg getSystem} function to determine the system that the target of each line is being built for
  ##  Files will be searched for assuming they contain {@arg pattern} in their name
  let nonroots :CTargets=  list.findNonRoots()                                    # 1. Find the root dependencies  (aka: list of code needed ; aka: NonRoots)
  var roots :RootTargets=  list.findRoots(nonroots, rootDir)                      # 2. Find what FinalTargets it builds  (aka its root objects)
  result = roots.toFinals(getMode, getSyst, getOS, getCPU, splitTarget, pattern)  # 3. Write the output into the result


#_______________________________________
# @descr Process MakeLists into Codegen Objects
#_____________________________
proc toCodegenList *(
    list        : MakeList;
    getMode     : GetModeFunc     = nil;
    getSyst     : GetSystemFunc   = nil;
    getOS       : ToOSFunc        = nil;
    getCPU      : ToCPUFunc       = nil;
    splitTarget : SplitTargetFunc = nil;
    pattern     : string          = ".c";
  ) :CodegenList=
  ## @descr
  ##  Converts the given makelist into its CodegenList representation.
  ##  Parses+Filters the inner lines of make output into their proper FinalTarget representation.
  ##  Stores the rest of the fields in the object as they were.
  echo &"\nGenerating Codegen List for:  {list.name}"
  result.name    = list.name
  result.key     = list.key
  result.trg     = list.toFinalTargets(list.root, getMode, getSyst, getOS, getCPU, splitTarget, pattern)
  result.genDir  = list.dir
  result.rootDir = list.root
  result.srcDir  = list.root # TODO: Change this to rootDir/src
#___________________
proc toCodegenLists *(
    lists       : MakeLists;
    getMode     : GetModeFunc     = nil;
    getSyst     : GetSystemFunc   = nil;
    getOS       : ToOSFunc        = nil;
    getCPU      : ToCPUFunc       = nil;
    splitTarget : SplitTargetFunc = nil;
    pattern     : string          = ".c";
  ) :CodegenLists=
  ## @descr
  ##  Converts the {@arg lists} of makelist into their CodegenList representation.
  ##  Parses+Filters the inner lines of each make output into their proper FinalTarget representation.
  ##  Stores the rest of the fields in the objects as they were.
  for list in lists: result.add list.toCodegenList(getMode, getSyst, getOS, getCPU, splitTarget, pattern)

