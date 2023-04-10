#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your project.nimble file.                       |
# Import dependencies are solved globally.             |
#_______________________________________________________
# std dependencies
import confy/RMV/paths
import std/strformat
import std/strutils
# confy dependencies
import confy/cfg
import confy/auto
import confy/tools
from   confy/state as c import nil

skipFiles &= @["confy.nim"]

#_________________________________________________
# Default nimble confy.task
#___________________
before confy: echo cfg.prefix,"This is happening before confy.task."
after  confy: echo cfg.prefix,"This is happening after confy.task."
task   confy, "This is the default nimble.confy task":
  sh &"{c.nimc} --outDir:{c.binDir} {c.srcDir/\"confy.nim\"}"   # nim -c --outDir:binDir srcDir/confy.nim
  withDir c.binDir: sh "./confy"

