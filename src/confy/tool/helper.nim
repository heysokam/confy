#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/osproc
import std/strformat
import std/strutils
import std/sequtils
import std/times
# confy dependencies
import ../types
import ../auto
import ../cfg
import ./logger


#_______________________________________
# General Tools
#_____________________________
proc sh *(cmd :string; dbg :bool= false) :void=
  ## Runs the given command in a shell (binary).
  if dbg: log cmd
  if cfg.fakeRun: return
  discard execShellCmd cmd
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
proc with *(os :OS; cpu :CPU) :System=
  ## Returns a System object for the given os and cpu.
  result.os  = os
  result.cpu = cpu
#_____________________________
proc setExec *(trg :Fil) :void=  trg.setFilePermissions({FilePermission.fpUserExec}, followSymlinks = false)
  ## Sets the given `trg` binary flags to be executable for the current user.


#_____________________________
proc getHost *() :System=
  ## Returns the properties of the host, as a System object
  case hostOS
  of   "windows":     result.os = OS.Windows
  of   "macosx":      result.os = OS.Mac
  of   "linux":       result.os = OS.Linux
  of   "netbsd":      result.os = OS.NetBSD
  of   "freebsd":     result.os = OS.FreeBSD
  of   "openbsd":     result.os = OS.OpenBSD
  of   "solaris":     result.os = OS.Solaris
  of   "aix":         result.os = OS.Aix
  of   "haiku":       result.os = OS.Haiku
  of   "standalone":  result.os = OS.Other
  else:               result.os = OS.Other
  case hostCPU
  of   "i386":        result.cpu = CPU.x86
  of   "amd64":       result.cpu = CPU.x86_64
  of   "arm":         result.cpu = CPU.arm
  of   "arm64":       result.cpu = CPU.arm64
  of   "mips":        result.cpu = CPU.mips
  of   "mipsel":      result.cpu = CPU.mipsel
  of   "mips64":      result.cpu = CPU.mips64
  of   "mips64el":    result.cpu = CPU.mips64el
  of   "powerpc":     result.cpu = CPU.powerpc
  of   "powerpc64":   result.cpu = CPU.powerpc64
  of   "powerpc64el": result.cpu = CPU.powerpc64el
  of   "sparc":       result.cpu = CPU.sparc
  of   "riscv32":     result.cpu = CPU.riscv32
  of   "riscv64":     result.cpu = CPU.riscv64
  of   "alpha":       result.cpu = CPU.alpha


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

