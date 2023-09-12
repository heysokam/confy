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
const debug       * = not (defined(release) or defined(danger)) or defined(debug)
template info  *(msg :string)= echo confyPrefix & msg
template info2 *(msg :string)= echo confyTab    & msg

#_________________________________________________
# Package information
#___________________
type Package = object
  name        :string
  version     :string
  author      :string
  description :string
  license     :string
#___________________
func getContent(line,pattern :string) :string=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getPackageInfo() :Package=
  when debug: info &"Getting .nimble data information from {projectDir()}"
  let data :seq[string]= gorgeEx( &"cd {projectDir()}; nimble dump" ).output.splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.name        = line.getContent("name")
    elif line.startsWith("version:") : result.version     = line.getContent("version")
    elif line.startsWith("author:")  : result.author      = line.getContent("author")
    elif line.startsWith("desc:")    : result.description = line.getContent("desc")
    elif line.startsWith("license:") : result.license     = line.getContent("license")
    #ignored: skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, requires, bin, binDir, srcDir, backend
  when debug: info2 &"found ->  {result}"

#_________________________________________________
# Requirements list
#___________________
proc installRequires *() :void {.inline.}=
  # remember "nimble list -i"
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
func asignOrFail (v1,v2,name :string) :string= result = if v1 != "": v1 elif v2 != "": v2 else: raise newException(IOError, "Tried to assign values for required variable "&name&" but none of the options are defined.")
#___________________
# Package Config
when debug:
  info "Asigning Package information variables..."
  for name,field in nimble.fieldPairs:
    if field == "": info2 "package."&name&" was not found in .nimble"
system.packageName = asignOrFail(system.packageName, nimble.name,        "packageName")
system.version     = asignOrFail(system.version,     nimble.version,     "version")
system.author      = asignOrFail(system.author,      nimble.author,      "author")
system.description = asignOrFail(system.description, nimble.description, "description")
system.license     = asignOrFail(system.license,     nimble.license,     "license")
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

