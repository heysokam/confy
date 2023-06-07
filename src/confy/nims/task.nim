#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your project.nims file.                         |
# Import dependencies are solved globally.             |
#_______________________________________________________
# std dependencies
import std/os
import std/strformat
import std/strutils
# confy dependencies
from   ../cfg as cfg import nil
import ../auto
import ../tools


#_________________________________________________
# Default nimble confy.task
#___________________
template beforeConfy= echo cfg.prefix,"This is happening before confy.task."
template afterConfy= echo cfg.prefix,"This is happening after confy.task."
proc confy *() :void=
  ## This is the default confy task
  beforeConfy
  let builder = &"{cfg.srcDir}/{cfg.file}"
  sh &"{cfg.nimc} --outDir:{cfg.binDir} {builder}"   # nim -c --outDir:binDir srcDir/build.nim
  withDir cfg.binDir: sh &"./{cfg.file.toString.splitFile.name}"
  afterConfy

