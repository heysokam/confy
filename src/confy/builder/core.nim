#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
# confy dependencies
import ../types
import ../logger
import ../dirs
# Builder module dependencies
import ./gcc as cc

#_____________________________
proc build *(obj :var BuildTrg) :void=
  log &"Setting up {obj.root}"; obj.root.setup()
  log &"Building {obj.trg}";    cc.compile(obj.src, obj.trg)

