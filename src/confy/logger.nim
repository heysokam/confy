#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# confy dependencies
import ./cfg


proc log *(msg :varargs[string, `$`]) :void=
  ## Reports information about the build process.
  ## Current: echo to cli with prefix
  echo cfg.prefix, msg[0]
  for id,arg in msg.pairs:
    if id == 0: continue
    echo cfg.tab, arg

