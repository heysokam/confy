#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os except `/`
# confy dependencies
import ../../cfg


#___________________
const name * = "zig"
const ext    = when defined(windows): ".exe" else: ""
const zcc    = name&" cc"
const zpp    = name&" c++"
#___________________
# Cannot be let/var, otherwise they are not configurable by zigSystemBin
template getRealCC  *() :string=
  if cfg.zigSystemBin: zcc  else: cfg.zigDir/( name & ext & " cc")
template getRealCCP *() :string=
  if cfg.zigSystemBin: zpp  else: cfg.zigDir/( name & ext & " c++")
template getRealBin *() :string=
  if cfg.zigSystemBin: name else: cfg.zigDir/( name & ext )
