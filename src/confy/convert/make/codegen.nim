# @deps std
from std/enumutils import symbolName
import std/sequtils
import std/sets
# @deps ndk
import nstd/strings
import nstd/paths
import nstd/sets
import confy
# @deps convert.make
import ./types



##[
#_____________________________
type FinalTarget * = object
  ## @descr Intermediate Representation (IR) Data that describes a single final binary compiled from Make
  bin      *:Path                ## Output binary that results from compilation
  binDir   *:Path                ## Folder where the binary will be output
  subDir   *:Path                ## Subdir of binDir where the binary will be output
  mode     *:BuildMode           ## release/debug
  kind     *:BuildKind           ## Program, SharedLib, etc
  system   *:System              ## CPU/OS
  globs    *:CodeDirs            ## Folders that can be globbed entirely
  excepts  *:CodeDirs            ## Folders that need to be filtered in some way
  lflags   *:OrderedSet[string]  ## Set of Linker Flags to compile this binary target
type FinalTargets * = seq[FinalTarget]

#_____________________________
type CodegenList * = object
  ## @descr List of binaries compiled from a single Make keyword
  name     *:string        ## Identifiable name for the list. Will become the name of the temp file.
  key      *:string        ## Keyword passed to make to create the data
  trg      *:FinalTargets  ## List of targets output by this command
  genDir   *:Path          ## Folder where the conversion result should be output
  srcDir   *:Path          ## Project folder where source code folder is stored
  rootDir  *:Path          ## Root folder of the project where make is called from
type CodegenLists * = seq[CodegenList]
]##


#_______________________________________
# @section confy: Code Generation
#_____________________________
const thisDir = currentSourcePath.Path.parentDir()
const templDir    {.strdefine.}= thisDir/".."/"templ"
const HeaderTempl {.strdefine.}= readFile templDir/"header.nim"
const TargetTempl {.strdefine.}= readFile templDir/"target.nim"
#___________________
func wrapped (val :string) :string= "\"" & val & "\""
func wrapped (path :Path)  :string=
  let words = path.string.split(DirSep)
  for id,val in words.pairs:
    if id != 0: result.add DirSep
    result.add val.wrapped
#___________________
func toWrappedSeq (
    list    : OrderedSet[Path] | OrderedSet[string];
    filters : openArray[string] = @[];
    label   : string            = "@[ ... ]"
  ) :string=
  let list = list.toSeq()
  let high = list.len - 1
  for id,entry in list.pairs:
    if id == 0: result.add "@[\n      "
    if entry.string notin filters:
      result.add entry.string.wrapped
      if id != high : result.add ",\n      "
    if id == high : result.add "\n      ] # << " & label
#___________________
func getName    (trg :FinalTarget) :string= trg.bin.lastPathPart.replace(".","_").string
func getTarget  (trg :FinalTarget) :string= trg.bin.lastPathPart.string.wrapped & ","
func getSystem  (trg :FinalTarget) :string= &"System(os: {$trg.system.os.symbolName}, cpu: {$trg.system.cpu.symbolName}),"
func getSubDir  (trg :FinalTarget) :string= trg.subDir.string.wrapped & ","
func getBinDir  (trg :FinalTarget) :string= trg.binDir.string.wrapped
proc getSrcDir  (srcDir,rootDir :Path) :string= srcDir.relativePath(rootDir).wrapped
#___________________
proc getSrcCode (trg :FinalTarget; srcDir,rootDir :Path) :string=
  result.add "toDirFile(\n    "
  # Add all fully globbed folders
  for id,glob in trg.globs.pairs:
    if glob.dir == "".Path: continue
    if id != 0: result.add " &\n    "
    result.add &"glob( cfg.srcDir/{glob.dir.wrapped} )"
  # Add all except filtered folders
  for id,excp in trg.excepts.pairs:
    if excp.dir == "".Path: continue
    var filters :string
    result.add " &\n    "
    for id,filter in excp.filters.pairs:
      if id != 0: filters.add ",\n      "
      filters.add &"cfg.srcDir/{filter.wrapped}"
    result.add &"glob( cfg.srcDir/{excp.dir.wrapped}, filters=\n      {filters} )"
  result.add "\n    ), # << src = @[ ... ]"
#___________________
const SkipCFlags = ["-MMD", "-x"]
const SkipLFlags = ["-shared"]
#___________________
func getFlags (trg :FinalTarget) :string=
  var cflags :OrderedSet[string]
  for dir in trg.globs   : cflags = cflags + dir.cflags
  for dir in trg.excepts : cflags = cflags + dir.cflags
  let CC = cflags.toWrappedSeq(SkipCFlags, "cc")
  let LD = trg.lflags.toWrappedSeq(SkipLFlags, "ld")
  result = fmt""" Flags(
    cc : {CC}
    ld : {LD}
    ), # << Flags( ... )"""
#___________________
proc getTargetCode (
    list    : CodegenList;
    trg     : FinalTarget;
    rootDir : Path = cfg.rootDir;
    srcDir  : Path = cfg.srcDir;
  ) :string=
  let Name       :string= trg.getName()
  let Build_Kind :string= $trg.kind
  let SrcDir     :string= "confy.cfg.rootDir/" & getSrcDir(srcDir, rootDir)
  let BinDir     :string= "confy.cfg.rootDir/" & trg.getBinDir()
  let Src        :string= trg.getSrcCode(srcDir, rootDir)
  let Trg        :string= trg.getTarget()
  let Syst       :string= trg.getSystem()
  let Subdir     :string= trg.getSubDir()
  let Flags      :string= trg.getFlags()
  let Make_Cmd   :string= list.key
  let rootRel    :string= list.rootDir.relativePath(rootDir).string
  let RootDir    :string= "ROOT/" & rootRel
  result = fmt(TargetTempl)
#___________________
const RootDirDefault = "getAppDir()/\"..\"  # Assumes that the confy builder is output into `cfg.binDir`"
proc getCode *(
    list        : CodegenList;
    trg         : FinalTarget;
    rootDir     : Path = cfg.rootDir;
    headerTempl : static string = "";
  ) :string=
  let RootDir :string= RootDirDefault
  let Trg = trg.bin.lastPathPart
  result = fmt( headerTempl ) & fmt( HeaderTempl ) & "\n" & list.getTargetCode(trg, rootDir, list.srcDir)
#___________________
proc getCode *(
    list        : CodegenList;
    rootDir     : Path = cfg.rootDir;
    headerTempl : static string = "";
  ) :string=
  let RootDir :string= RootDirDefault
  for trg in list.trg:
    let Trg = trg.bin.lastPathPart
    result = fmt( headerTempl ) & fmt( HeaderTempl )
    result.add "\n" & list.getTargetCode(trg, rootDir, list.srcDir)


#_______________________________________
# @section confy: Code Writing
#_____________________________
proc writeFile *(
    list        : CodegenList;
    trgDir      : Path;
    headerTempl : static string = "";
    unified     : bool = true;
    force       : bool = false;
  ) :void=
  if unified:
    let mode   = ($list.trg[0].mode).normalize
    let subDir = mode/list.genDir
    let dir    = trgDir/subDir
    let file   = (dir/list.name).addFileExt(".nim")
    md dir
    echo &"Writing generated code for {list.name} into:  {file}"
    file.writeFile list.getCode(cfg.rootDir, headerTempl)
  else:
    for trg in list.trg:
      let mode   = ($trg.mode).normalize
      let subDir = mode/list.genDir
      let dir    = trgDir/subDir
      md dir
      let file   = (dir/list.name).addFileExt(".nim")
      echo &"Writing generated code for {list.name} into:  {file}"
      file.writeFile list.getCode(trg, cfg.rootDir, headerTempl)
#___________________
proc writeFiles *(
    lists       : CodegenLists;
    trgDir      : Path;
    headerTempl : static string = "";
    unified     : bool = true;
    force       : bool = false;
  ) :void=
  ## @descr Writes all files that are described in the {@arg lists} of CodegenList objects
  for list in lists: list.writeFile(trgDir, headerTempl, unified, force)

