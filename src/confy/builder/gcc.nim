#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
import std/strformat
import std/strutils
# confy dependencies
import ../tools
import ../cfg
import ../state as c
import ../logger
# Builder Module dependencies
import ./base as baseBuilder ; export baseBuilder

let cc = if verbose: "gcc -v" else: "gcc"

#_____________________________
# GCC: Linker
#___________________
proc link *(src :seq[Path]; trg :Path) :void=
  ## Links the given `src` list of files into the `trg` binary.

#_____________________________
# GCC: Compiler
#___________________
proc compile *(src, trg :Path) :void=
  ## Compiles the given `src` file using `gcc`
  let cmd = &"{cc} {srcDir/src} -o {binDir/trg}"
  if verbose: echo cmd
  else:       echo &"{Cstr} {trg}"
  echo cmd; sh cmd

proc compile *(src :var seq[Path]; trg :Path) :void=
  ## Compiles the given `src` list of files using `gcc`
  for file in src.mitems:  file = srcDir/file
  compile join(src," "), trg

