#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Nimscript : Helpers  |
#______________________|
import ./guard
# std dependencies
import std/os
import std/strformat
import std/strutils
import std/sequtils
# nims dependencies
import ./confy


#___________________
let nimcr * = &"nim c -r --outdir:{cfg.binDir}"
  ## Compile and run, outputting to binDir.
proc runFile *(dir, file, args :string) :void=  exec &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command.
proc build *(args :string) :void=  runFile( cfg.srcDir, cfg.file, args )
  ## Orders to build the project, passing the given args to the builder app.
