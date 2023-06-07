#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your project.nimble file.                       |
# Import dependencies are solved globally.             |
#_______________________________________________________
# std dependencies
import std/os
import std/paths
import std/strformat
import std/strutils
# confy dependencies
from   ../cfg as cfg import nil
import ../auto
import ../tools

skipFiles.add cfg.file

#_________________________________________________
# Default nimble confy.task
#___________________
before confy: echo cfg.prefix,"This is happening before confy.task."
after  confy: echo cfg.prefix,"This is happening after confy.task."
task   confy, "This is the default nimble.confy task":
  sh &"{cfg.nimc} --outDir:{cfg.binDir} {cfg.srcDir/cfg.file}"   # nim -c --outDir:binDir srcDir/build.nim
  withDir cfg.binDir: sh &"./{cfg.file.splitFile.name}"

