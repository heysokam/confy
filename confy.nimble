#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
import std/[ os,strformat ]

#_____________________________
# Package
packageName   = "confy"
version       = "0.5.1"
author        = "sOkam"
description   = "confy | Buildsystem for Nim & C"
license       = "MIT"

#_____________________________
# Dependencies
requires "nim >= 1.9.1"
requires "jsony"
requires "https://github.com/guzba/zippy"
requires "https://github.com/heysokam/nstd#head"
requires "https://github.com/heysokam/get.Lang#head"

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

