#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
# confy dependencies
import ../auto
import ../cfg

#_________________________________________________
# Nim commands with Sane Defaults
#___________________
# Verbosity --
let switchVerbose   = if cfg.verbose: "--verbose" else: ""
let switchVerbosity = if cfg.verbose: "--verbosity:2" else: ""
# Commands
var nimble * = &"nimble {switchVerbose}"
var nimc   * = &"nim c {switchVerbosity} -d:release --gc:orc"

