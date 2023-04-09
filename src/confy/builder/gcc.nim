#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
# confy dependencies
import ./tools


#_____________________________
# GCC: Compiler
#___________________
proc compile *(src :string) :void=
  ## Compiles the given `src` file using `gcc`
  sh "echo src"

proc compile *(src :openArray[string]) :void=
  ## Compiles the given `src` list of files using `gcc`
  for file in files:  compile file


#_____________________________
# GCC: Linker
#___________________
proc link *(src :openArray[string]; trg :string) :void=
  ## Links the given `src` list of files into the `trg` binary.
