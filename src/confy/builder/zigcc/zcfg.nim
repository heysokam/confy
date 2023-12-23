#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# confy dependencies
import ../../cfg
import ../../tool/paths


#___________________
const name * = "zig"
const ext    = when defined(windows): ".exe" else: ""
const zcc    = name&" cc"
const zpp    = name&" c++"
#___________________
# Cannot be let/var, otherwise they are not configurable by zigcc.systemBin
template getRealCC  *() :string=
  if cfg.zigcc.systemBin: zcc  else: string cfg.zigDir/( name & ext & " cc")
template getRealCCP *() :string=
  if cfg.zigcc.systemBin: zpp  else: string cfg.zigDir/( name & ext & " c++")
template getRealBin *() :string=
  if cfg.zigcc.systemBin: name else: string cfg.zigDir/( name & ext )
