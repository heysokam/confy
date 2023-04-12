#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
# confy dependencies
import ../types
import ../logger
import ../dirs
import ../tools/db
# Builder module dependencies
import ./gcc as cc

#_____________________________
proc build *(obj :var BuildTrg) :void=
  obj.root.setup()
  cc.compile(obj.src, obj.trg)

