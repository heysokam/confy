#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
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
var cc      * = if cfg.zigSystemBin: zcc else: cfg.zigDir/zcc
var ccp     * = if cfg.zigSystemBin: zpp else: cfg.zigDir/zpp
let realBin * = if cfg.zigSystemBin: name else: cfg.zigDir/name

