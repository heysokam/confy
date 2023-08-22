#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your project.nims file.                         |
# Import dependencies are solved globally.             |
#_______________________________________________________
import ./guard
# std dependencies
import std/os
import std/strformat
import std/strutils
# confy dependencies
import ./confy
import ./helper
# nims dependencies
import ./types
import ./confy
import ./helper


#_________________________________________________
# Default nimble confy.task
#___________________
template beforeConfy= log "Building the current project with confy ..."
template afterConfy=  log "Done building."
proc confy *(file :string= cfg.file.string) :void=
  ## This is the default confy task
  beforeConfy
  let builder = (&"{cfg.srcDir.string}/{file}").addFileExt(".nim")
  sh &"{cfg.nimc} -d:ssl --outDir:{cfg.binDir.string} {builder}"   # nim -c -d:ssl --outDir:binDir srcDir/build.nim
  withDir cfg.binDir: sh &"./{cfg.file.string.splitFile.name}"
  afterConfy


#_________________________________________________
# Task: any
#___________________
var anyc :Cfg
anyc.src = if cliArgs.len > 2: cliArgs[2] else: ""
let name = anyc.src.splitFile.name
anyc.bin = cfg.binDir/name
anyc.run = &"{anyc.bin} {anyc.opts}"
anyc.bld = &"nim c {anyc.nimc} -o:{anyc.bin} {anyc.src}"
#____________________________________________
proc beforeAny () :void=
  log " Building  ",anyc.src,"  file into   ",cfg.binDir.string
proc afterAny  () :void=
  log "Done building. Running...  ",anyc.run
  exec anyc.run
  anyc.bin.rmFile  # Remove the binary output file when done
#____________________________________________
proc any *() :void=
  ## Builds any given source code file into binDir. Useful for testing/linting individual files.
  beforeAny()
  if cliArgs.len < 2: cerr "The any command expects a source file as its first argument after they `any` keyword."
  exec anyc.bld
  afterAny()

