#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps ndk
import nstd/strings
# @deps confy
import ../types
import ../cfg

#_______________________________________
# @section Logger base tools
#_____________________________
proc log0 *(msg :string) :void=  echo cfg.prefix, msg
  ## @descr Level0 log. For logging the title of a category of steps.
proc log1 *(msg :string) :void=  echo cfg.tab, msg
  ## @descr Level1 log. For logging the submessages of a category of steps.
#___________________
proc log *(msg :varargs[string, `$`]) :void=
  ## @descr
  ##  Reports information about the build process.
  ##  Current: echo to cli with prefix
  log0 msg[0]
  for id,arg in msg.pairs:
    if id == 0: continue
    log1 arg

#_______________________________________
# @section Logger API
#_____________________________
proc info  *(msg :string) :void= log0 msg
proc info2 *(msg :string) :void= log1 msg
#___________________
proc wrn *(args :varargs[string, `$`]) :void=  echo cfg.prefix & "! WRN ! " & args.toString
  ## @descr Reports a warning message to console.
#___________________
proc dbg *(args :varargs[string, `$`]) :void=
  ## @descr Reports a message to console. Does nothing if {@arg cfg.verbose} is disabled.
  if not cfg.verbose: return
  log0 args.join(" ")

#_______________________________________
# @section Error Management
#_____________________________
template cerr*(args :varargs[string, `$`]) :void=  raise newException(CompileError, args.toString)
  ## @descr Raises a compile exception error with the given message.
template gerr*(args :varargs[string, `$`]) :void=  raise newException(GeneratorError, args.toString)
  ## @descr Raises a compile exception error with the given message.

