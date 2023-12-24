#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
import std/[ os,strformat ]

#_____________________________
# Package
packageName   = "confy"
version       = "0.2.0"
author        = "sOkam"
description   = "confy | Buildsystem for Nim & C"
license       = "MIT"

#_____________________________
# Dependencies
requires "nim >= 2.0.0"
# TODO:
# requires "db_connector"
# requires "checksums"
requires "jsony"
requires "zippy"

#_____________________________
# Folders
srcDir = "src"
binDir = "bin"

#_____________________________
# Examples
#___________________
import ./examples/helper
task examples,    "Builds all examples for all languages."                : helper.buildAll()
task examplesC,   "Builds all examples for the C   programming language." : helper.buildAll( C   )
task examplesCpp, "Builds all examples for the C++ programming language." : helper.buildAll( Cpp )
# TODO:
# task examplesNim, "Builds all examples for the Nim programming language." : helper.buildAll( Nim )
# task helloC,      "Builds the hello world example for the C   programming language." : helper.build( C  , Hello )
# task helloCpp,    "Builds the hello world example for the C++ programming language." : helper.build( Cpp, Hello )
# task helloNim,    "Builds the hello world example for the Nim programming language." : helper.build( Nim, Hello )

#_________________________________________________
# Internal
#___________________
task push, "Internal:  Pushes the git repository, and orders to create a new git tag for the package, using the latest version.":
  # @note Does nothing when local and remote versions are the same.
  requires "https://github.com/beef331/graffiti.git"
  helper.push()

