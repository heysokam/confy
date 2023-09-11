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
# confy dependencies
import ./cfg
import ./tool/opts
import ./tool/logger

const debug = not (defined(release) or defined(danger))

#_________________________________________________
# Internal Types
#___________________
type Keyword = object
  name  :string
  descr :string
  file  :string
proc hash *(obj :Keyword) :Hash=  hash(obj.name)
proc `==` *(a,b :Keyword) :bool=  a.name == b.name
#___________________
type Package * = object
  name        *:string
  version     *:string
  author      *:string
  description *:string
  license     *:string

#_________________________________________________
# Package information
#___________________
func getContent(line,pattern :string) :string=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getPackageInfo *() :Package=
  if debug: info &"Getting package information from {cfg.rootDir}"
  let data :seq[string]= execCmdEx( &"cd {cfg.rootDir}; nimble dump" ).output.splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.name        = line.getContent("name")
    elif line.startsWith("version:") : result.version     = line.getContent("version")
    elif line.startsWith("author:")  : result.author      = line.getContent("author")
    elif line.startsWith("desc:")    : result.description = line.getContent("desc")
    elif line.startsWith("license:") : result.license     = line.getContent("license")
    #ignored: skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, requires, bin, binDir, srcDir, backend
  if debug: info2 &"found ->  {result}"
#___________________
let package * = getPackageInfo()

#_________________________________________________
# Requirements list
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
# Keywords
#___________________
var keywordList = initOrderedSet[Keyword]()
#___________________
template docgen *()=
  ## Internal keyword
  ## Generates the package documentation using Nim's docgen tools.
  ## TODO: Remove hardcoded repo user
  info "Starting docgen..."
  exec &"nim doc --project --index:on --git.url:https://github.com/heysokam/{package.name} --outdir:doc/gen src/{package.name}.nim"
  info "Done with docgen."
#___________________
template tests *()=
  ## Internal keyword
  ## Builds and runs all tests in the testsDir folder.
  for file in cfg.testsDir.listFiles():
    if file.lastPathPart.startsWith('t'):
      try: runFile file
      except: echo &" └─ Failed to run one of the tests from  {file}"
#___________________
template push *()=
  ## Internal keyword
  ## Pushes the git repository, and orders to create a new git tag for the package, using the latest version.
  ## Does nothing when local and remote versions are the same.
  exec "nimble install https://github.com/beef331/graffiti.git"
  exec "git push"  # Requires local auth
  exec &"graffiti ./{package.name}.nimble"
#___________________
proc keyword *(name,descr,file :string) :void {.inline.}=  keywordList.incl Keyword(name:name, descr:descr, file:file)
  ## Generates a keyword to send to the confy builder as input
  # let sname = astToStr(name)  # string name
  # if   sname == "docgen" : docgen()
  # elif sname == "tests"  : tests()
proc keyword *(name :static string) :void {.inline.}=  keyword name, "NoDescription", "NoFile"
  ## Generates a keyword to send to the confy builder as input


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
proc runTest *(file :string) :void=  file.runFile(cfg.testsDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
proc runExample *(file :string) :void=  file.runFile(cfg.examplesDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
template example *(name :untyped; descr,file :static string)=
  ## Generates a task to build+run the given example
  let sname = astToStr(name)  # string name
  requires sname, "SomePackage__123"  ## Doc
  keyword sname, descr, file
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

