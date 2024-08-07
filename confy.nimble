
{.warning:"""
The Nim-based confy toolset is deprecated,
and will be removed as soon as the zig rewrite is completed.
""".}

#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
when not defined(nimscript) : import system/nimscript # Silence nimsuggest errors


#_____________________________
# Package
packageName   = "confy"
version       = "0.6.3"
author        = "sOkam"
description   = "confy | Buildsystem for Nim & C"
license       = "MIT"

#_____________________________
# Dependencies
requires "nim >= 2.0.0"
requires "jsony"
requires "https://github.com/guzba/zippy"
requires "https://github.com/heysokam/nstd#head"
requires "https://github.com/heysokam/get.Lang#head"

#_____________________________
# Folders
srcDir = "src/deprecated"
binDir = "bin"

#_____________________________
# Examples
#___________________
import ./src/deprecated/examples/helper
task examples,    "Builds all examples for all languages."                           : helper.buildAll()
task examplesC,   "Builds all examples for the C   programming language."            : helper.buildAll( C   )
task examplesCpp, "Builds all examples for the C++ programming language."            : helper.buildAll( Cpp )
task examplesNim, "Builds all examples for the Nim programming language."            : helper.buildAll( Nim )
task helloC,      "Builds the hello world example for the C   programming language." : helper.buildHello( C   )
task helloCpp,    "Builds the hello world example for the C++ programming language." : helper.buildHello( Cpp )
task helloNim,    "Builds the hello world example for the Nim programming language." : helper.buildHello( Nim )

