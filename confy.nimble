#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
import std/[ os,strformat ]

#_____________________________
# Package
packageName   = "confy"
version       = "0.3.10"
author        = "sOkam"
description   = "confy | Buildsystem for Nim & C"
license       = "MIT"

#_____________________________
# Dependencies
requires "nim >= 2.0.0"
requires "jsony"
requires "zippy"
requires "https://github.com/heysokam/nstd#head"

#_____________________________
# Folders
srcDir = "src"
binDir = "bin"

#_____________________________
# Examples
#___________________
import ./examples/helper
task examples,    "Builds all examples for all languages."                           : helper.buildAll()
task examplesC,   "Builds all examples for the C   programming language."            : helper.buildAll( C   )
task examplesCpp, "Builds all examples for the C++ programming language."            : helper.buildAll( Cpp )
task examplesNim, "Builds all examples for the Nim programming language."            : helper.buildAll( Nim )
task helloC,      "Builds the hello world example for the C   programming language." : helper.buildHello( C   )
task helloCpp,    "Builds the hello world example for the C++ programming language." : helper.buildHello( Cpp )
task helloNim,    "Builds the hello world example for the Nim programming language." : helper.buildHello( Nim )

#_________________________________________________
# Internal
#___________________
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  # @note Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  helper.push()

