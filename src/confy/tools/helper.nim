#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/os


#_____________________________
# General Tools
proc sh *(cmd :string) :void=
  when defined(nimscript): exec cmd
  else:                    discard execShellCmd cmd

