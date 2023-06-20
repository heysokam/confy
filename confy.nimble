#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
import std/os
import std/strformat

#_____________________________
# Package
packageName   = "confy"
version       = "0.0.3"
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

#_________________________________________________
# Manage git tags for confy
#___________________
taskRequires "push", "https://github.com/beef331/graffiti.git"
task push, "Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  ## Does nothing when local and remote versions are the same.
  exec "git push"  # Requires local auth
  exec "graffiti ./confy.nimble"
