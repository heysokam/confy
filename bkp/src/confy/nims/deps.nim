#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
import ./guard


proc requires *(deps :varargs[string]) :void=
  ## Nims support: Call this to set the list of requirements of your application.
  for d in deps: requiresData.add(d)
