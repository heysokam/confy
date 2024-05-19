#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/enumutils import symbolName
from std/algorithm import sort
import std/sequtils
# @deps ndk
import nstd/strings
import nstd/paths
import nstd/sets
import confy
# @deps convert.make
import ./types
import ../tools
import ./parse/checks


#_______________________________________
# @section confy: Code Generation
#_____________________________
const echo = debugEcho
const thisDir = currentSourcePath.Path.parentDir()
const templDir    {.strdefine.}= thisDir/".."/"templ"
const HeaderTempl {.strdefine.}= staticRead templDir/"header.nim"
const TargetTempl {.strdefine.}= staticRead templDir/"target.nim"
#___________________
const ConnectorCallSimpleTempl {.strdefine.}= """
proc build *(run :bool= false; force :bool= false) :void=
"""
const ConnectorCallTempl {.strdefine.}= """
proc build *(
    systems : openArray[System]    = [confy.getHost()];
    modes   : openArray[BuildMode] = [Release];
    run     : bool                 = false;
    force   : bool                 = false
  ) :void=
"""

#_____________________________
func wrapped (val :string; safeWrap :bool= false) :string=
  result.add "\""
  result.add if not safeWrap: val else: val.replace("\\\"", "\\\\\\\"")
  result.add "\""
#___________________
func wrapped (
    path   : Path;
    prefix : static string = "";
    strip  : static string = "";
  ) :string=
  # @note This function used to be clear and clean T_T
  let words = path.string.split(DirSep)
  if prefix != "": result.add prefix & $DirSep
  var skip :bool
  for id,val in words.pairs:
    if val == strip:
      if id == 0: skip = true
      continue
    if id != 0:
      if skip : skip = false
      else    : result.add DirSep
    result.add val.string.wrapped
#___________________
func wrapped (
    list   : seq[Path];
    prefix : static string = "";
    strip  : static string = "";
  ) :seq[string]=
  for file in list: result.add file.wrapped(prefix, strip)
#___________________
func wrapped (
    list   : CodeFiles;
    prefix : static string = "";
    strip  : static string = "";
  ) :seq[string]=
  for code in list: result.add code.file.wrapped(prefix, strip)
#_____________________________
func toCodeSeq [T :string | Path](
    list      : OrderedSet[T] | seq[T];
    tab       : string            = "    ";
    label     : string            = "@[ ... ]";
    sep       : string            = ",";
    filters   : openArray[string] = @[];
    innerWrap : bool              = true;
    safeWrap  : bool              = false;
  ) :string=
  ## @descr Converts the given {@arg list} of {@arg T} into its code representation
  if list.len == 0: return &"@[]{sep}"
  let list = when list isnot openArray[T]: list.toSeq() else: list
  let high = list.len - 1
  for id,entry in list.pairs:
    if id == 0: result.add &"@[\n{tab}"
    if entry.string notin filters:
      result.add if innerWrap: entry.string.wrapped(safeWrap=safeWrap) else: entry.string
      if id != high : result.add &",\n{tab}"
    if id == high:
      result.add &"\n{tab}]{sep}"
      if label != "": result.add &" # << {label}"
#___________________
func changeExt (path :Path; ext :string= "") :Path=
  if ext != "": path.changeFileExt(ext) else: path
#___________________
func getName    (trg :FinalTarget) :string= trg.bin.lastPathPart.replace(".","_").string
func getTarget  (trg :FinalTarget) :string= trg.bin.lastPathPart.string.wrapped & ","
func getSystem  (trg :FinalTarget) :string= &"System(os: {$trg.system.os.symbolName}, cpu: {$trg.system.cpu.symbolName}),"
func getSubDir  (trg :FinalTarget) :string= trg.subDir.string.wrapped & ".Path,"
func getBinDir  (trg :FinalTarget) :string= trg.binDir.string.wrapped
proc getSrcDir  (srcDir,rootDir :Path) :string= srcDir.relativePath(rootDir).wrapped
#___________________
proc getSrcCode (
    trg     : FinalTarget;
    srcDir  : Path;
    rootDir : Path;
    strip   : static string= "";
  ) :string=
  # Add all explicitly listed source files
  if trg.deps.len != 0:
    result.add trg.deps.wrapped(prefix="cfg.binDir", strip=strip).toCodeSeq(
      tab       = "    ",
      label     = "",
      sep       = ".toDirFile()",
      filters   = @[],
      innerWrap = false,
      ) # << trg.src.toCodeSeq( ... )
  if trg.src.len != 0:
    if trg.deps.len != 0: result.add " &\n    "
    result.add trg.src.wrapped(prefix="cfg.srcDir").toCodeSeq(
      tab       = "    ",
      label     = "",
      sep       = ".toDirFile()",
      filters   = @[],
      innerWrap = false,
      ) # << trg.src.toCodeSeq( ... )
  # Add all fully globbed folders
  for id,glob in trg.globs.pairs:
    if glob.dir == "".Path: continue
    if (trg.src.len != 0 or trg.deps.len != 0) and id == 0: result.add " &"
    result.add "\n    "
    let tmp = glob.dir.wrapped(strip=strip)
    result.add &"glob( cfg.srcDir/{tmp} )"
    if id != trg.globs.high: result.add " &"
  # Add all except filtered folders
  for id,excp in trg.excepts.pairs:
    if excp.dir == "".Path: continue
    var filters :seq[string]
    result.add " &\n    "
    for filter in excp.filters.items:
      let tmp = filter.wrapped(strip=strip)
      filters.add &"cfg.srcDir/{tmp}"
    const Tab = "      "
    let filtersCode = filters.toCodeSeq(
      tab       = Tab,
      label     = " filters[ ... ]",
      sep       = ",",
      innerWrap = false,
      ) # << filters.toCodeSeq( ... )
    let tmp = excp.dir.wrapped
    result.add &"glob( cfg.srcDir/{tmp}, filters= {filtersCode}\n{Tab})"
  result.add ", # << src = @[ ... ]"
#___________________
const SkipCFlags    = ["-MMD"]
const SkipLFlags    = ["-shared"]
const SkipAssembler = ["-x", "assembler-with-cpp"]
#___________________
func getFlags (trg :FinalTarget) :string=
  let assembler = trg.isAssembler()
  # Find the complete list of cflags
  var cflags :OrderedSet[string]
  for src in trg.src: # Add the flags for all src files
    for flag in src.flags:
      if assembler or flag notin SkipAssembler: cflags.incl flag
  for dir in trg.globs: # Add the flags for all globbed dirs
    for flag in dir.cflags:
      if assembler or flag notin SkipAssembler: cflags.incl flag
  for dir in trg.excepts:  # Add the flags for all glob+excepts dirs
    for flag in dir.cflags:
      if assembler or flag notin SkipAssembler: cflags.incl flag
  # Codegen the CC and LD lists
  let CC = cflags.toCodeSeq(
    filters   = SkipCFlags,
    label     = "cc",
    tab       = "      ",
    sep       = ",",
    innerWrap = true,
    safeWrap  = true,
    ) # << cflags.toCodeSeq( ... )
  let LD = if trg.kind == Object: "@[]," else: trg.lflags.toCodeSeq(
    filters   = SkipLFlags,
    label     = "ld",
    tab       = "      ",
    sep       = ",",
    innerWrap = true,
    safeWrap  = true,
    ) # << trg.lflags.toCodeSeq( ... )
  result = fmt"""Flags(
    cc : {CC}
    ld : {LD}
    ), # << Flags( ... )"""
#___________________
proc getTargetCode (
    list    : CodegenList;
    trg     : FinalTarget;
    rootDir : Path = cfg.rootDir;
    srcDir  : Path = cfg.srcDir;
    strip   : static string = "";
  ) :string=
  let ext        :string= if trg.kind == Object and trg.system.os == Windows: ".obj" else: ""
  let Name       :string= trg.getName()
  let Build_Kind :string= $trg.kind
  let SrcDir     :string= "confy.cfg.rootDir/" & getSrcDir(srcDir, rootDir)
  let BinDir     :string= "confy.cfg.rootDir/" & trg.getBinDir()
  let Src        :string= trg.getSrcCode(srcDir, rootDir, strip)
  let Trg        :string= trg.getTarget()
  let Syst       :string= trg.getSystem()
  let Subdir     :string= trg.getSubDir()
  let Flags      :string= trg.getFlags()
  let Make_Cmd   :string= list.key
  let rootRel    :string= list.rootDir.relativePath(rootDir).string
  let RootDir    :string= "ROOT/" & rootRel
  result = fmt( TargetTempl )
#___________________
const RootDirDefault = "getAppDir()/\"..\"  # Assumes that the confy builder is output into `cfg.binDir`"
proc getCode *(
    list        : CodegenList;
    trg         : FinalTarget;
    rootDir     : Path = cfg.rootDir;
    headerTempl : static string = "";
    strip       : static string = "";
  ) :string=
  let RootDir :string= RootDirDefault
  let Trg = trg.bin.lastPathPart
  result = fmt( headerTempl ) & "\n" & fmt( HeaderTempl ) & "\n" & list.getTargetCode(trg, rootDir, list.srcDir, strip)
#___________________
proc getCode *(
    list        : CodegenList;
    rootDir     : Path = cfg.rootDir;
    headerTempl : static string = "";
    strip       : static string = "";
  ) :string=
  let RootDir :string= RootDirDefault
  var Trg :string
  for id,trg in list.trg.pairs:
    if id != 0: Trg.add ", "
    Trg.add trg.bin.lastPathPart.string
  result = fmt( headerTempl ) & "\n" & fmt( HeaderTempl )
  for trg in list.trg:
    result.add "\n" & list.getTargetCode(trg, rootDir, list.srcDir, strip)
  result.add "\n"
#___________________
proc getConnectorCode *(trg :FinalTarget; onlyCall :bool= false) :string=
  if not onlyCall: result.add ConnectorCallSimpleTempl
  let run   = if trg.kind == Program: " run=run," else: ""
  let force = " force=force "
  result.add &"  {trg.getName()}.build({run}{force})\n"
#___________________
proc getConnectorCode *(list :CodegenList) :string=
  result.add ConnectorCallSimpleTempl
  for trg in list.trg:
    result.add trg.getConnectorCode( onlyCall=true )
  result.add "\n"


#_______________________________________
# @section confy: Code Writing
#_____________________________
proc writeAndReport (
    file  : Path;
    code  : string;
    list  : CodegenList;
    force : bool = false;
  ) :void=
  ## @internal
  ## @descr
  ##  Writes {@arg code} into the output {@arg file} when it is appropiate.
  ##  Also reports what is happening to CLI
  ## @note Created only to avoid code duplication
  if force: reportForcedWarning()
  if force or not fileExists(file):
    echo &"Writing generated code for {list.name} into:  {file}"
    file.writeFile code
  else: echo &"Omitting code generation for {list.name}. The target file already exists:  {file}"
#___________________
proc writeFile *(
    list        : CodegenList;
    trgDir      : Path;
    headerTempl : static string = "";
    strip       : static string = "";
    unified     : bool = true;
    connector   : bool = true;
    force       : bool = false;
  ) :Connectors=
  if unified:
    # Generate the BuildTrg code
    let mode   = ($list.trg[0].mode).normalize
    let subDir = mode/list.genDir
    let dir    = trgDir/subDir
    let file   = (dir/list.name).addFileExt(".nim")
    md dir
    var code = list.getCode(cfg.rootDir, headerTempl, strip)
    # Generate the connector
    if connector:
      code.add list.getConnectorCode()
      result.add Connector(path: file, mode: list.trg[0].mode, system: list.trg[0].system)
    # Write the output to the target file  (if appropiate)
    file.writeAndReport(code, list, force)
  else:
    for trg in list.trg:
      # Generate the BuildTrg code
      let mode   = ($trg.mode).normalize
      let subDir = mode/list.genDir
      let dir    = trgDir/subDir
      let file   = (dir/list.name).addFileExt(".nim")
      md dir
      var code = list.getCode(trg, cfg.rootDir, headerTempl, strip)
      # Generate the connector
      if connector:
        code.add trg.getConnectorCode()
        result.add Connector(path: file, mode: trg.mode, system: trg.system)
      # Write the output to the target file  (if appropiate)
      file.writeAndReport(code, list, force)
#___________________
func getCode *(system :System) :string=
  result = &"System(os: {system.os.symbolName}, cpu: {system.cpu.symbolName})"
#___________________
proc getAlias (connector :Connector; trgDir :Path) :string=
  result = connector.path.relativePath(trgDir).changeFileExt("").replace($DirSep, "_").string
#___________________
proc toImportCode (connector :Connector; trgDir :Path) :string=
  result = &"import {connector.path.relativePath(trgDir).changeFileExt(\"\")} as {connector.getAlias(trgDir)}\n"
#___________________
proc toBuildCall (connector :Connector; trgDir :Path) :string=
  result = &"  if {connector.mode.symbolName} in modes and {connector.system.getCode()} in systems: {connector.getAlias(trgDir)}.build( run=run, force=force )\n"
#___________________
proc writeFile *(
    connectors  : Connectors;
    trgDir      : Path;
    headerTempl : static string = "";
    force       : bool = false;
  ) :Path {.discardable.}=
  let builder = trgDir/"builder.nim"
  if force or not fileExists(builder):
    var imports :string
    var code    :string= "import confy\n"
    code.add ConnectorCallTempl
    for connector in connectors:
      imports.add connector.toImportCode(trgDir)
      code.add connector.toBuildCall(trgDir)
    if force: reportForcedWarning()
    echo &"Writing builder connector code into:  {builder}"
    let Trg = "All Targets"
    builder.writeFile( fmt(headerTempl) & "\n" & imports & "\n" & code & "\n" )
    result = builder
  else: echo &"Omitting builder connector code generation. The target file already exists:  {builder}"

#___________________
proc cmp *(A,B :Connector) :int=  system.cmp(A.path.string, B.path.string)
#___________________
proc writeFiles *(
    lists       : CodegenLists;
    trgDir      : Path;
    headerTempl : static string = "";
    strip       : static string = "";
    unified     : bool = true;
    connector   : bool = true;
    force       : bool = false;
  ) :seq[Path] {.discardable.}=
  ## @descr Writes all files that are described in the {@arg lists} of CodegenList objects
  var connectors :Connectors
  for list in lists: connectors &= list.writeFile(trgDir, headerTempl, strip, unified, connector, force)
  connectors.sort( codegen.cmp )
  if connector: result.add connectors.writeFile(trgDir, headerTempl, force)
  for file in connectors: result.add file.path

