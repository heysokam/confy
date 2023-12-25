#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# confy dependencies
import ../../cfg
import ../../tool/paths


#___________________
const name * = "zig"
const cc     = " cc"
const cpp    = " c++"
const ar     = " ar"
const ext    = when defined(windows): ".exe" else: ""
const zcc    = name&" cc"
const zpp    = name&" c++"
const zar    = name&" ar"
#___________________
# Cannot be let/var, otherwise they are not configurable by zigcc.systemBin
template getRealCC  *() :string=
  if cfg.zigcc.systemBin: zcc  else: string cfg.zigDir/( name & ext & cc)
template getRealCCP *() :string=
  if cfg.zigcc.systemBin: zpp  else: string cfg.zigDir/( name & ext & cpp)
template getRealAR  *() :string=
  if cfg.zigcc.systemBin: zar  else: string cfg.zigDir/( name & ext & ar)
template getRealBin *() :string=
  if cfg.zigcc.systemBin: name else: string cfg.zigDir/( name & ext )
