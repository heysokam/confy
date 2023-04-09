#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os

proc sh *(cmd :string) :void=
  when defined(nimscript): exec cmd
  else:                    discard execShellCmd cmd

proc requires
proc glob

