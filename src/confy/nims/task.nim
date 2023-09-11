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
import std/sequtils
# nims dependencies
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
  sh &"./{cfg.file.string.splitFile.name}", cfg.binDir
  afterConfy
