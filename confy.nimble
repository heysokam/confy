#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
import std/os
import std/strformat

#_____________________________
# Package
packageName   = "confy"
version       = "0.0.0"
author        = "sOkam"
description   = "confy buildsystem"
license       = "MIT"

#_____________________________
# Dependencies
requires "nim >= 1.9.3"
requires "db_connector"
requires "checksums"
requires "jsony"
requires "zippy"

#_____________________________
# Folders
srcDir          = "src"
binDir          = "bin"
let examplesDir = "examples"
let helloDir    = examplesDir/"hello"

#_________________________________________________
# Run the example demo project
#___________________
before demo: echo packageName,": This is happening before hello.task."
after  demo: echo packageName,": This is happening after hello.task."
task demo, "Executes confy inside the demo folder":
  withDir helloDir: exec "nim hello.nims"

