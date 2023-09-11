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
import std/[ os,strformat,strutils,sets ]


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
# Package information
#___________________
type Package = object
  name    :string
  version :string
  author  :string
  descr   :string
  license :string
#___________________
func getContent(line,pattern :string) :string=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getPackageInfo() :Package=
  if debug: info &"Getting .nimble data information from {projectDir()}"
  let data :seq[string]= gorgeEx( &"cd {projectDir()}; nimble dump" ).output.splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.name    = line.getContent("name")
    elif line.startsWith("version:") : result.version = line.getContent("version")
    elif line.startsWith("author:")  : result.author  = line.getContent("author")
    elif line.startsWith("desc:")    : result.descr   = line.getContent("desc")
    elif line.startsWith("license:") : result.license = line.getContent("license")
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
# Package information
var nimble :Package= getPackageInfo()
const Undefined = "Undefined Variable -> Must Declare"
#___________________
# Package Config
system.packageName = if nimble.name    != "": nimble.name    else: Undefined
system.version     = if nimble.version != "": nimble.version else: Undefined
system.author      = if nimble.author  != "": nimble.author  else: Undefined
system.description = if nimble.descr   != "": nimble.descr   else: Undefined
system.license     = if nimble.license != "": nimble.license else: Undefined
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

