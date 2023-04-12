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
from   confy/cfg as c import nil
import confy/auto
import confy/tools

skipFiles.add c.file

#_________________________________________________
# Default nimble confy.task
#___________________
before confy: echo c.prefix,"This is happening before confy.task."
after  confy: echo c.prefix,"This is happening after confy.task."
task   confy, "This is the default nimble.confy task":
  sh &"{c.nimc} --outDir:{c.binDir} {c.srcDir/c.file}"   # nim -c --outDir:binDir srcDir/build.nim
  withDir c.binDir: sh &"./{c.file.splitFile.name}"

