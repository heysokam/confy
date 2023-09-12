#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/osproc
import std/strformat
import std/strutils
import std/hashes
import std/sets
import std/strscans
# confy dependencies
import ./cfg
import ./tool/opts
import ./tool/logger

const debug = not (defined(release) or defined(danger)) or defined(debug)

#_________________________________________________
# Build Helpers
#_____________________________
# TODO
const vlevel = when debug: 2 else: 1
let nimcr = &"nim c -r --verbosity:{vlevel} --outdir:{cfg.binDir}"
  ## Compile and run, outputting to binDir
proc runFile *(file, dir, args :string) :void=  discard execShellCmd &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command, and passing it the given args
proc runFile *(file :string) :void=  file.runFile( "", "" )
  ## Runs file using the nimcr command

#_________________________________________________
# Package information
#___________________
type Package * = object
  name        *:string
  version     *:string
  author      *:string
  description *:string
  license     *:string
#___________________
func getContent(line,pattern :string) :string=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getPackageInfo *() :Package=
  when debug: info &"Getting package information from {cfg.rootDir}"
  let data :seq[string]= execCmdEx( &"cd {cfg.rootDir}; nimble dump" ).output.splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.name        = line.getContent("name")
    elif line.startsWith("version:") : result.version     = line.getContent("version")
    elif line.startsWith("author:")  : result.author      = line.getContent("author")
    elif line.startsWith("desc:")    : result.description = line.getContent("desc")
    elif line.startsWith("license:") : result.license     = line.getContent("license")
    #ignored: skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, requires, bin, binDir, srcDir, backend
  when debug:
    if result.name == ""        : info2 "Package name wasn't found in .nimble"
    if result.version == ""     : info2 "Package version wasn't found in .nimble"
    if result.author == ""      : info2 "Package author wasn't found in .nimble"
    if result.description == "" : info2 "Package description wasn't found in .nimble"
    if result.license == ""     : info2 "Package license wasn't found in .nimble"
#___________________
let package * = getPackageInfo()

#_________________________________________________
# Build Requirements list
#___________________
var requiresData :seq[string]
#___________________
template installRequires *()=
  info "Installing dependencies declared with `requires`"
  var confyID    :Natural
  var confyFound :bool
  for id,req in tasks.requiresData.pairs:
    var dep :string
    if   req == "confy"         : dep = "https://github.com/heysokam/confy@#head"; confyID = id; confyFound = true
    elif req.endsWith("@#head") : dep = req
    elif req.endsWith("#head")  : dep = req.replace("#head", "@#head")
    info2 "Installing "&dep
    exec "nimble install "&dep
  if confyFound: system.requiresData.delete(confyID) # Remove confy requires so we dont install it multiple times
#___________________
template clearRequires *()=  tasks.requiresData = @[]

#___________________
type DepVers = object
  id       :string
  checksum :string
type DepInfo = object
  name     :string
  versions :seq[DepVers]
type Dependencies = seq[DepInfo]
#___________________
proc getInstalledDeps () :Dependencies=
  ## Gets the list of already installed dependecies on the system.
  for it in execCmdEx( "nimble list -i" ).output.splitLines():
    var tmp      :DepInfo
    var versStr  :string
    var versList :seq[string]
    if scanf(it, "$*[$*]$.", tmp.name, versStr):
      tmp.name = tmp.name.splitWhitespace().join()
      versList = versStr.replace("(","").split("), ")
    for ver in versList.mitems:
      ver = ver.replace(")","")
      var vstr   :string
      var chksum :string
      if scanf(ver, "version: $*, checksum: $*", vstr, chksum):
        tmp.versions.add DepVers(id:vstr, checksum:chksum)
    result.add tmp
#___________________
proc isInstalled (dep :string) :bool=
  ## Returns true if the dependency is installed in the system.
  ## TODO -> conditions for version management
  for it in getInstalledDeps():
    if it.name in dep: return true
#___________________
proc require *(dep :string; force=false) :void {.inline.}=
  ## Installs the given dependency using nimble
  ## TODO Install when a new version exists  (currently downloads only when not installed)
  if force or not dep.isInstalled(): discard os.execShellCmd &"nimble install {dep}"


#_______________________________________
# Keywords
#___________________
proc getKeywordList *(cli :CLI) :OrderedSet[string]=
  for arg in cli.args:
    if not arg.fileExists(): result.incl arg
var keywordList *:OrderedSet[string]=  getCLI().getKeywordList()


#_______________________________________
# Examples
#___________________
template example *(name :untyped; descr,file :static string; deps :seq[string]; runv=true; forcev=false)=
  ## Generates a BuildTrg to build+run the given example.
  ## The example will be built either when its keyword `name` or when the `examples` keyword are sent.
  ## All dependencies in `deps` will be installed before.
  let prevSrcDir = cfg.srcDir
  let sname  = astToStr(name)  # string name
  cfg.srcDir = cfg.examplesDir
  var `name` = Program.new(cfg.examplesDir.string/file, sname)
  for dep in deps: require dep
  `name`.build(@["examples", sname], run=`runv`, force=`forcev`)
  cfg.srcDir = prevSrcDir


#_______________________________________
# Task List
#___________________
type TaskCallback = proc():void
type Task = object
  name  :string
  descr :string
  call  :TaskCallback
proc hash *(obj :Task) :Hash=  hash(obj.name)
proc `==` *(a,b :Task) :bool=  a.name == b.name
#___________________
var taskList = initOrderedSet[Task]()
proc task *(name,descr :string; call :TaskCallback; always=off; categories :seq[string]= @[]) :void {.inline.}=
  ## Creates a generic task to execute.
  ## Runs the task where it is declared if its name is found in the user-requested keywords.
  ##
  ## The task will run if:
  ## - `always` is active.   (The task will always run, no matter if it was requrested or not)
  ## - Its `name` is found in the user-requested keywords.
  ## - The keyword "tasks" is requested.   (Requesting `tasks` in cli will make all defined tasks run)
  ## - One of the categories is found in the user-requested keywords.
  taskList.incl Task(name:name, descr:descr, call:call)
  if always or "tasks" in keywordList : call()
  elif name in keywordList            : call()
  elif categories.len != 0:
    for it in categories:
      if it in keywordList: call()
#___________________
proc runAllTasks *() :void {.inline.}=
  ## Runs all tasks known by confy (ie: all tasks in the taskList), no matter if they were requested in CLI or not.
  for it in taskList: it.call()
#_____________________________
# Preset Tasks
#___________________
proc docgen *() :void=
  ## Internal keyword
  ## Generates the package documentation using Nim's docgen tools.
  ## TODO: Remove hardcoded repo user
  info "Starting docgen..."
  discard execShellCmd &"nim doc --project --index:on --git.url:https://github.com/heysokam/{package.name} --outdir:doc/gen src/{package.name}.nim"
  info "Done with docgen."
#___________________
proc tests *()=
  ## Internal keyword
  ## Builds and runs all tests in the testsDir folder.
  for file in cfg.testsDir.walkDir():
    if file.path.lastPathPart.startsWith('t'):
      try: runFile file.path
      except: echo &" └─ Failed to run one of the tests from  {file}"
#___________________
proc push *()=
  ## Internal task
  ## Pushes the git repository, and orders to create a new git tag for the package, using the latest version.
  ## Does nothing when local and remote versions are the same.
  require "https://github.com/beef331/graffiti.git"
  discard execShellCmd "git push"  # Requires local auth
  discard execShellCmd &"graffiti ./{package.name}.nimble"
#___________________
# Add them to the internal list
task "docgen" , "Generates the package documentation using Nim's docgen tools.", docgen
task "tests"  , "Builds and runs all tests in the testsDir folder.", tests
task "push"   , "Pushes the git repository, and orders to create a new git tag for the package, using the latest version.", push



#_________________________________________________
# Task: any
#___________________
# TODO
type Cfg = object # Storage of compiling profile options
  nimc  :string   # Options to pass to the compiler itself
  opts  :string   # Options to pass to the binary when its run
  bin   :string   # Output name of the binary file
  bld   :string   # Command to build the files needed for the task
  run   :string   # Command to run in the task
  src   :string   # Source code file to compile
#___________________
var anyc :Cfg
let anyArgs = getArgs()
anyc.src = if anyArgs.len > 2: anyArgs[2] else: ""
let name = anyc.src.splitFile.name
anyc.bin = cfg.binDir/name
anyc.run = &"{anyc.bin} {anyc.opts}"
anyc.bld = &"nim c {anyc.nimc} -o:{anyc.bin} {anyc.src}"
#____________________________________________
proc beforeAny () :void=
  log " Building  ",anyc.src,"  file into   ",cfg.binDir.string
proc afterAny  () :void=
  log "Done building. Running...  ",anyc.run
  discard execShellCmd anyc.run
  anyc.bin.removeFile  # Remove the binary output file when done
#____________________________________________
proc any *() :void=
  ## Builds any given source code file into binDir. Useful for testing/linting individual files.
  beforeAny()
  if anyArgs.len < 2: cerr "The any command expects a source file as its first argument after they `any` keyword."
  discard execShellCmd anyc.bld
  afterAny()

