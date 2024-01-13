#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/strutils import join
# @deps confy
import ../types
import ../cfg
#___________________
# std extensions
func toString *(args :varargs[string]) :string=
  ## Converts the given string varargs to a single string.
  for arg in args:  result.add arg

var stdout {.importc: "stdout", header: "<stdio.h>".} :File
proc prnt *(args :varargs[string, `$`]) :void=  stdout.write toString(args)
  ## Prints the input to console, without "\n" at the end.

#___________________
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

proc info  *(msg :string) :void= log0 msg
proc info2 *(msg :string) :void= log1 msg

proc wrn *(args :varargs[string, `$`]) :void=  echo cfg.prefix & "! WRN ! " & args.toString
  ## Reports a warning message to console.

proc dbg *(args :varargs[string, `$`]) :void=
  ## Reports a message to console. Does nothing if {@link cfg.verbose} is disabled.
  if not cfg.verbose: return
  log0 args.join(" ")

template cerr*(args :varargs[string, `$`]) :void=  raise newException(CompileError, args.toString)
  ## Raises a compile exception error with the given message.
template gerr*(args :varargs[string, `$`]) :void=  raise newException(GeneratorError, args.toString)
  ## Raises a compile exception error with the given message.

