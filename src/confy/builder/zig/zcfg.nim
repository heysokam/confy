#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
# confy dependencies
import ../../cfg


#___________________
const name * = "zig"
const zcc    = name&" cc"
const zpp    = name&" c++"
#___________________
var cc  * = cfg.zigDir/zcc
var ccp * = cfg.zigDir/zpp

