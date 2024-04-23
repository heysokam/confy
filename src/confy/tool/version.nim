#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview Version Management tools
#__________________________________________|
# @deps ndk
from nstd/typetools as nstd import nil
import ../types {.all.} as confy

#_____________________________
func version *(M,m,p :SomeInteger) :confy.Version=  nstd.version[VersT](M.VersT, m.VersT, p.VersT)
  ## @descr Creates a {@link confy.Version} object with Major ID {@arg M}, minor ID {@arg m}, and patch ID {@arg p}
#_____________________________
func `$` *(v :Version) :string=
  ## @descr Turns the {@arg v} version into its formatted string representation
  nstd.toString(
    v       = v,
    prefix  = "v",
    sep     = ".",
    postfix = "",
    )  # << nstd.toString ( ... )
