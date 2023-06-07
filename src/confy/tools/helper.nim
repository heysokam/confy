#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
# when not defined(nimscript): import confy/RMV/osproc
# confy dependencies
import ../types
import ../auto
import ../cfg
import ../logger


#_______________________________________
# General Tools
#_____________________________
proc sh *(cmd :string; dbg :bool= false) :void=
  ## Runs the given command in a shell.
  if dbg: log cmd
  when defined(nimscript): exec cmd
  else:
    if cfg.fakeRun: return
    discard execShellCmd cmd
#_____________________________
##[
proc sh *(cmds: openArray[string]; cores :int) :void=
  ## Runs the given commands in parallel, using the given number of cores.
  ## When used with nimscript, it ignores cores and runs the commands one after the other.
  when defined(nimscript):
    for cmd in cmds: exec cmd
  else:
    discard execProcesses(cmds, n = cores)
]##

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

