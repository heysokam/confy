# std dependencies
import std/osproc
when defined(nimscript):
  import std/strformat
import std/strutils
import std/times
# confy dependencies
import ../types
import ../auto
import ../cfg
import ./logger


# #_______________________________________
# # General Tools
# #_____________________________
# proc sh *(cmd :string; dbg :bool= false) :void=
#   ## Runs the given command in a shell (binary).
#   if dbg: log cmd
#   if cfg.fakeRun: return
#   discard execShellCmd cmd
#_____________________________
proc sh *(cmds: openArray[string]; cores :int= cfg.cores) :void=
  ## Runs the given commands in parallel, using the given number of cores.
  ## When used with nimscript, it ignores cores and runs the commands one after the other.
  # todo:  https://github.com/mratsim/constantine/blob/master/helpers/pararun.nim
  when defined(nimscript):
    for cmd in cmds: exec cmd
  else:
    discard execProcesses(cmds, n=cores, options={poUsePath, poStdErrToStdOut, poParentStreams})

#_____________________________
proc touch *(trg :Fil) :void=
  ## Creates the target file if it doesn't exist.
  when defined(nimscript):
    when defined linux:   exec &"touch {trg}"
    elif defined windows: exec &"Get-Item {trg}"
  else:  trg.open(mode = fmAppend).close

#_____________________________
proc setExec *(trg :Fil) :void=  trg.setFilePermissions({FilePermission.fpUserExec}, followSymlinks = false)
  ## Sets the given `trg` binary flags to be executable for the current user.


when not defined(nimscript):
  #_____________________________
  proc lastMod *(trg :Fil) :times.Time=
    ## Returns the last modification time of the file, or empty if it cannot be found.
    try:    result = trg.getLastModificationTime
    except: result = Time()
  #_____________________________
  proc noModSince *(trg :Fil; hours :SomeInteger) :bool=  ( times.getTime() - trg.lastMod ).inHours > hours
    ## Returns true if the trg file hasn't been modified in the last N hours.

#_______________________________________
# std Extension
#___________________
proc startsWith *(entry :string; args :varargs[string, `$`]) :bool=
  for arg in args:
    if strutils.startsWith(entry, arg): return true

