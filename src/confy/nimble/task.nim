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
import std/strformat
import std/strutils
# confy dependencies
import confy/cfg


#_________________________________________________
# Default nimble confy.task
#___________________
before confy: echo cfg.prefix,"This is happening before confy.task."
after  confy: echo cfg.prefix,"This is happening after  confy.task."
task   confy, "This is the default nimble.confy task":
  for it in 0..<3:
    echo cfg.prefix, &"This is task step{it}"

