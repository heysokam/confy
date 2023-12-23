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

#_____________________________
# Folders
srcDir              = "src"
binDir              = "bin"

#_____________________________
# Examples
import ./examples/helper
task examplesC,   "Builds all of the examples for the C   programming language." : helper.buildAll( C   )
task examplesCpp, "Builds all of the examples for the C++ programming language." : helper.buildAll( Cpp )
task examplesNim, "Builds all of the examples for the Nim programming language." : helper.buildAll( Nim )
