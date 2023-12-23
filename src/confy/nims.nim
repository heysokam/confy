#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your confy.nims file.                           |
# Import dependencies are solved globally.             |
#_______________________________________________________
include ./nims/guard
# @deps std
import std/[ os,strformat,strutils,sequtils,sets ]
# @deps confy
import ./types
import ./cfg

#_________________________________________________
# General tools
#___________________
template info  *(msg :string)= echo cfg.prefix & msg
template info2 *(msg :string)= echo cfg.tab    & msg
template fail  *(msg :string)= quit cfg.prefix & msg
#___________________
proc asignOrFail (v1,v2,name :string) :string=
  ## @descr Returns either the value of `v1` or `v2`, and fails if both of them are empty.
  result = if v1 != "": v1 elif v2 != "": v2 else: fail "Tried to assign values for required variable "&name&" but none of the options are defined."
  when debug: info2 &"found {name}:  {result}"
#___________________
proc sh *(cmd :string; dir :string= ".") :void=
  ## @descr Runs the given command with a shell.
  ## @arg cmd The command to run
  ## @arg dir The folder from which the {@link:arg cmd} command will be run.
  if not cfg.quiet: info &"Running {cmd} from {dir} ..."
  try:
    withDir dir: exec cmd
  except: fail &"Failed running {cmd}"
  if not cfg.quiet: info &"Done running {cmd}."

#___________________
proc cliParams *() :seq[string]=
  ## @descr Returns the list of all Command Line Parameters passed to the script.
  const KnownAliases = ["confy"]
  var valid :bool= false
  for id in 0..paramCount():
    let curr = paramStr( id )
    if   id == 0 and curr in KnownAliases : valid = true     # Special case for aliased script used as arg0
    elif valid                            : result.add curr  # Everything is valid after arg0 was found
    elif curr.endsWith(".nims")           : valid = true     # Add everything after we found arg0 (case: the first .nims file)
proc cliArgs *() :seq[string]=  cliParams().filterIt( not it.startsWith('-') )
  ## @descr List of command line arguments passed to the nims script.
proc cliOpts *() :seq[string]=  cliParams().filterIt( it.startsWith('-') )
  ## @descr List of command line options passed to the nims script.


#_________________________________________________
# Configuration
#___________________
# Internal Config
proc getPackageInfo () :Package=
  func getContent (line,pattern :string) :string=  line.replace( pattern & ": \"", "").replace("\"", "")
  when debug: info &"Getting package information"
  if packageName != "" : result.name        = packageName
  if version     != "" : result.version     = version
  if author      != "" : result.author      = author
  if description != "" : result.description = description
  if license     != "" : result.license     = license
  if packageName != "" and version != "" and author != "" and description != "" and license != "":
     when debug: info2 &"{result}"
     return
  # Nimble
  when debug: info &"One of the variables is not defined. Searching for .nimble file in {projectDir()}  Running\n  nimble dump"
  let data :seq[string]= gorgeEx( &"cd {projectDir()}; nimble dump" ).output.splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.name        = line.getContent("name")
    elif line.startsWith("version:") : result.version     = line.getContent("version")
    elif line.startsWith("author:")  : result.author      = line.getContent("author")
    elif line.startsWith("desc:")    : result.description = line.getContent("desc")
    elif line.startsWith("license:") : result.license     = line.getContent("license")
    #ignored: skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, requires, bin, binDir, srcDir, backend
  when debug: info2 &"{result}"

#_________________________________________________
# Requirements list
#___________________
proc requires *(deps :varargs[string]) :void=
  ## Nims support: Call this to set the list of requirements of your application.
  for d in deps: requiresData.add(d)
#___________________
proc installRequires *() :void {.inline.}=
  # remember "nimble list -i"
  when debug: info "Installing dependencies declared with `requires`"
  var confyID    :Natural
  var confyFound :bool
  for id,req in system.requiresData.pairs:
    var dep :string
    if   req == "confy"         : dep = "https://github.com/heysokam/confy@#head"; confyID = id; confyFound = true
    elif req.endsWith("@#head") : dep = req
    elif req.endsWith("#head")  : dep = req.replace("#head", "@#head")
    when debug: info2 "Installing "&dep
    exec "nimble install "&dep
  if confyFound: system.requiresData.delete(confyID) # Remove confy requires so we dont install it multiple times
#___________________
template clearRequires *()=  system.requiresData = @[]

#_________________________________________________
# Default confy.task
#___________________
when not compiles(beforeConfy()):
  proc beforeConfy= info "Building the current project with confy ..."
when not compiles(afterConfy()):
  proc afterConfy=  info "Done building."
proc confy *(file :string= cfg.file.string) :void=
  ## This is the default confy task
  beforeConfy()
  let builder = (&"{cfg.srcDir.string}/{file}").addFileExt(".nim")
  sh &"{cfg.nim.cc} c -d:ssl --skipParentCfg -d:release --outDir:{cfg.binDir.string} {builder}"   # nim c --outDir:binDir srcDir/build.nim
  sh &"./{cfg.file.string.splitFile.name} {cliParams().join(\" \")}", cfg.binDir
  afterConfy()

#_________________________________________________
# Process: nims
#_____________________________
when isMainModule and (nims or defined(nimble)):
  # Initialize
  when debug: info "Starting in debug mode"
  # Build Requirements
  when not defined(nimble): installRequires()
  # Package information
  var pkgInfo :Package= getPackageInfo()
  when debug: info "Asigning package information"
  system.packageName = asignOrFail(system.packageName, pkgInfo.name,        "packageName")
  system.version     = asignOrFail(system.version,     pkgInfo.version,     "version")
  system.author      = asignOrFail(system.author,      pkgInfo.author,      "author")
  system.description = asignOrFail(system.description, pkgInfo.description, "description")
  system.license     = asignOrFail(system.license,     pkgInfo.license,     "license")
  #___________________
  # Folders Config
  when debug: info "Defining and asigning folder paths"
  system.binDir      = cfg.binDir
  system.srcDir      = cfg.srcDir
  var docDir       * = cfg.docDir
  var examplesDir  * = cfg.examplesDir
  var testsDir     * = cfg.testsDir
  var cacheDir     * = cfg.cacheDir
  # Terminate and send control to the user script
  when debug: info "Done setting up $1 configuration" % [when defined(nimble): "nimble" else: "nims"]

