#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# confy dependencies
import ../types
import ../tools
# Builder module dependencies
import ./gcc as cc

#_____________________________
proc build *(obj :BuildObj) :void=
  obj.root.setup()
  cc.compile(obj.src[0])





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

