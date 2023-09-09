#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your confy.nims file.                           |
# Import dependencies are solved globally.             |
#_______________________________________________________
include ./nims/guard
# confy dependencies for nims
from ./nims/confy as c import nil
# std dependencies
import std/[ os,strformat,strutils ]


#_________________________________________________
# Internal Types
#___________________
type Nimble = object
  packageName :string
  version     :string
  author      :string
  description :string
  license     :string
#___________________
type Keyword = object
  name  :string
  descr :string
  file  :string
proc hash *(obj :Keyword) :Hash=  hash(obj.name)
proc `==` *(a,b :Keyword) :bool=  a.name == b.name


#_________________________________________________
# Configuration
#___________________
# Internal Config
const confyPrefix * = "confy: "
const confyTab    * = "     : "
const debug       * = not (defined(release) or defined(danger))
template info  *(msg :string)= echo confyPrefix & msg
template info2 *(msg :string)= echo confyTab    & msg

#_________________________________________________
# Nimble information
#___________________
func getContent(line,pattern :string) :string=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getNimbleInfo() :Nimble=
  if debug: info &"Getting .nimble data information from {projectDir()}"
  let data :seq[string]= gorgeEx( &"cd {projectDir()}; nimble dump" ).output.splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.packageName = line.getContent("name")
    elif line.startsWith("version:") : result.version     = line.getContent("version")
    elif line.startsWith("author:")  : result.author      = line.getContent("author")
    elif line.startsWith("desc:")    : result.description = line.getContent("desc")
    elif line.startsWith("license:") : result.license     = line.getContent("license")
    #ignored: skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, requires, bin, binDir, srcDir, backend
  if debug: info2 &"found ->  {result}"

#_________________________________________________
# Requirements list
#___________________
template installRequires *()=
  info "Installing dependencies declared with `requires`"
  var confyID    :Natural
  var confyFound :bool
  for id,req in system.requiresData.pairs:
    var dep :string
    if   req == "confy"         : dep = "https://github.com/heysokam/confy@#head"; confyID = id; confyFound = true
    elif req.endsWith("@#head") : dep = req
    elif req.endsWith("#head")  : dep = req.replace("#head", "@#head")
    info2 "Installing "&dep
    exec "nimble install "&dep
  if confyFound: system.requiresData.delete(confyID) # Remove confy requires so we dont install it multiple times
#___________________
template clearRequires *()=  system.requiresData = @[]


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
  exec &"nim doc --project --index:on --git.url:https://github.com/heysokam/{packageName} --outdir:doc/gen src/{packageName}.nim"
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
  exec &"graffiti ./{system.packageName}.nimble"
#___________________
template keyword *(name,descr :static string; file :string)=
  ## Generates a keyword to send to the confy builder as input
  keywordList.incl Keyword(name:name, descr:descr, file:file)
  # let sname = astToStr(name)  # string name
  # if   sname == "docgen" : docgen()
  # elif sname == "tests"  : tests()
template keyword *(name :static string)=  keyword name, "NoDescription", "NoFile"
  ## Generates a keyword to send to the confy builder as input


#_________________________________________________
# Build Helpers
#_____________________________
# TODO
const vlevel = when debug: 2 else: 1
let nimcr  = &"nim c -r --verbosity:{vlevel} --outdir:{c.binDir}"
  ## Compile and run, outputting to binDir
proc runFile (file, dir, args :string) :void=  exec &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command, and passing it the given args
proc runFile (file :string) :void=  file.runFile( "", "" )
  ## Runs file using the nimcr command
proc runTest (file :string) :void=  file.runFile(c.testsDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
proc runExample (file :string) :void=  file.runFile(c.examplesDir, "")
  ## Runs the given test file. Assumes the file is stored in the default testsDir folder
template example (name :untyped; descr,file :static string)=
  ## Generates a task to build+run the given example
  let sname = astToStr(name)  # string name
  taskRequires sname, "SomePackage__123"  ## Doc
  task name, descr:
    runExample file


#___________________
# nims confy+any tasks
include ./nims/task



#_________________________________________________
# Initialize
#_____________________________
when debug: info "Starting in debug mode"
#___________________
# Build Requirements
installRequires()
#___________________
# Nimble information
var nimble :Nimble= getNimbleInfo()
const Undefined = "Undefined Variable -> Must Declare"
#___________________
# Package Config
system.packageName = if nimble.packageName != "": nimble.packageName else: Undefined
system.version     = if nimble.version     != "": nimble.version     else: Undefined
system.author      = if nimble.author      != "": nimble.author      else: Undefined
system.description = if nimble.description != "": nimble.description else: Undefined
system.license     = if nimble.license     != "": nimble.license     else: Undefined
#___________________
# Folders Config
system.binDir      = c.binDir
system.srcDir      = c.srcDir
var docDir       * = c.docDir
var examplesDir  * = c.examplesDir
var testsDir     * = c.testsDir
var cacheDir     * = c.cacheDir
#___________________
# Binaries Config
system.backend     = "c"
#___________________
# Terminate and send control to the user script
info "Done setting up."
