#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
import std/strformat
# confy dependencies
import ../tools
import ../cfg
import ../state as c
# Builder Module dependencies
import ./base as baseBuilder ; export baseBuilder

let cc = if cfg.verbose: "gcc -v" else: "gcc"

#_____________________________
# GCC: Compiler
#___________________
proc compile *(src :Path) :void=
  ## Compiles the given `src` file using `gcc`
  echo "inside compile:"
  sh "ls -ah"
  sh &"echo {src}"
  sh &"{cc} {srcDir/src}"

proc compile *(src :seq[Path]) :void=
  ## Compiles the given `src` list of files using `gcc`
  for file in src:  compile file


#_____________________________
# GCC: Linker
#___________________
proc link *(src :seq[Path]; trg :Path) :void=
  ## Links the given `src` list of files into the `trg` binary.
