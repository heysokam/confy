#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
{.error:"Tasks and keywords need to be reimplemented for the refactor of 2.0.0".}
# std dependecies
import std/os
import std/osproc
import std/strformat
import std/strscans
# confy dependecies
import ../tool/strings


#___________________
type DepVers = object
  id       :string
  checksum :string
type DepInfo = object
  name     :string
  versions :seq[DepVers]
type Dependencies = seq[DepInfo]
#___________________
var firstRun :bool= on
var depsData :Dependencies
#___________________
proc getInstalled () :Dependencies=
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
  for it in depsData:
    if it.name in dep: return true
#___________________
proc require *(dep :string; force=false) :void {.inline.}=
  ## Installs the given dependency using nimble
  ## TODO Install when a new version exists  (currently downloads only when not installed)
  if firstRun: depsData = deps.getInstalled(); firstRun = off
  if force or not dep.isInstalled(): discard os.execShellCmd &"nimble install {dep}"






##[
# TODO : Currently only nimscript does this
#_________________________________________________
# Build Requirements list
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
template clearRequires *()=  deps.requiresData = @[]
]##

