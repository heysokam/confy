#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# confy dependencies
import ./cfg

proc log0 *(msg :string) :void=  echo cfg.prefix, msg
  ## Level0 log. For logging the title of a category of steps.
proc log1 *(msg :string) :void=  echo cfg.tab, msg
  ## Level1 log. For logging the submessages of a category of steps.

proc log *(msg :varargs[string, `$`]) :void=
  ## Reports information about the build process.
  ## Current: echo to cli with prefix
  log0 msg[0]
  for id,arg in msg.pairs:
    if id == 0: continue
    log1 arg
