#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
# confy dependencies
import ../types
import ../tools
import ../logger
# Builder module dependencies
import ./gcc as cc

#_____________________________
proc build *(obj :var BuildObj) :void=
  log &"Setting up {obj.root}"; obj.root.setup()
  log &"Building {obj.trg}";    cc.compile(obj.src, obj.trg)





##[
#_____________________________
proc build *(kind :BinKind; src :string) :void=
  ## Compiles a Binary of the given Kind, from the given `src` file
  cc.compile(src)
#_____________________________
proc build *(kind :BinKind; src :openArray[string]) :void= discard
  ## Compiles a Binary of the given Kind, from the given `src` list of files
  for file in src:  kind.build(file)
#_____________________________
proc build *(src :string) :void= discard
  ## Compiles a Program from the given `src` file
  Program.build(src)
#_____________________________
proc build *(src :openArray[string]) :void= discard
  ## Compiles a Program from the given `src` list of files
  for file in src:  Program.build(file)
  ## Compiles a Program from the given `src` list of files
]##

