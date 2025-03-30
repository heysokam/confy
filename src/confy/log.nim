#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/strutils import join, `%`
# @deps confy
from ./types/errors import SomeToolError
from ./types/build import BuildTarget
from ./cfg import nil


#_______________________________________
# @section Base Logging Tools
#_____________________________
func base (pfx :string; msg :varargs[string, `$`]) :void= debugEcho(pfx, " ", msg.join(" "))

#_______________________________________
# @section Default Config
#_____________________________
func info *(msg :varargs[string, `$`]) :void= log.base(pfx= cfg.tool_prefix&cfg.log_info,  msg)
func warn *(msg :varargs[string, `$`]) :void= log.base(pfx= cfg.tool_prefix&cfg.log_warn,  msg)
func err  *(msg :varargs[string, `$`]) :void= log.base(pfx= cfg.tool_prefix&cfg.log_error, msg)
func dbg  *(msg :varargs[string, `$`]) :void= log.base(pfx= cfg.tool_prefix&cfg.log_debug, msg)
func verb *(msg :varargs[string, `$`]) :void=
  if cfg.tool_verbose: log.base(pfx= cfg.tool_prefix&cfg.log_info,  msg)
template fail *(Err :CatchableError; msg :varargs[string, `$`])=
  ## Marks a block of code as an unrecoverable fatal error. Raises an exception when entering the block.
  ## For debugging unexpected errors on the buildsystem.
  const inst = instantiationInfo()
  const info = "$#($#,$#): " % [inst.fileName, $inst.line, $inst.column]
  raise newException(Err, cfg.tool_prefix&cfg.log_fatal & " " & info & " " & msg.join(" "))



#_______________________________________
# @section Per-Target
#_____________________________
func info *(trg :BuildTarget; msg :varargs[string, `$`]) :void= log.base(pfx= trg.cfg.prefix&cfg.log_info,  msg)
func warn *(trg :BuildTarget; msg :varargs[string, `$`]) :void= log.base(pfx= trg.cfg.prefix&cfg.log_warn,  msg)
func err  *(trg :BuildTarget; msg :varargs[string, `$`]) :void= log.base(pfx= trg.cfg.prefix&cfg.log_error, msg)
func dbg  *(trg :BuildTarget; msg :varargs[string, `$`]) :void= log.base(pfx= trg.cfg.prefix&cfg.log_debug, msg)
func verb *(trg :BuildTarget; msg :varargs[string, `$`]) :void=
  if trg.cfg.verbose: log.base(pfx= trg.cfg.prefix&cfg.log_info, msg)

template fail *(trg :BuildTarget; Err :typedesc[SomeToolError]; msg :varargs[string, `$`])=
  ## Marks a block of code as an unrecoverable fatal error. Raises an exception when entering the block.
  ## For debugging unexpected errors on the buildsystem.
  const inst = instantiationInfo()
  const info = "$#($#,$#): " % [inst.fileName, $inst.line, $inst.column]
  raise newException(Err, trg.cfg.prefix&cfg.log_fatal & " " & info & " " & msg.join(" "))

