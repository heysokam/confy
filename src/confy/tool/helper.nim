#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/times
# @deps confy
import ../types
import ../cfg
# @deps confy.tools
import ./strings


#_______________________________________
# General Tools
#_____________________________
# Bash
proc sh *(cmd :string; dbg :bool= false) :void=
  ## @descr Runs the given command in a shell (binary).
  if dbg: echo cmd
  if cfg.fakeRun: return
  discard os.execShellCmd cmd
#___________________
# Access time
when not nims:
  #_____________________________
  proc lastMod *(trg :Fil) :times.Time=
    ## @descr Returns the last modification time of the file, or empty if it cannot be found.
    try:    result = os.getLastModificationTime( trg.string )
    except: result = times.Time()
  #_____________________________
  proc noModSince *(trg :Fil; hours :SomeInteger) :bool=  ( times.getTime() - trg.lastMod ).inHours > hours
    ## @descr Returns true if the trg file hasn't been modified in the last N hours.
#_____________________________
# Files
proc touch *(trg :Fil) :void=
  ## @descr Creates the target file if it doesn't exist.
  when nims:
    when defined linux:   exec &"touch {trg}"
    elif defined windows: exec &"Get-Item {trg}"
  else:  trg.string.open(mode = fmAppend).close
#_____________________________
proc setExec *(trg :Fil) :void=  os.setFilePermissions(trg.string, {FilePermission.fpUserExec}, followSymlinks = false)
  ## @descr Sets the given `trg` binary flags to be executable for the current user.


#_______________________________________
# Compiler
#_____________________________
proc defaultExt *(lang :Lang) :string=
  ## @descr Returns the default extension for the given lang as a string  (contains the dot).
  ## @note Result will be an empty string if the lang is Unknown
  case lang
  of Nim,C,Cpp : "." & ($lang).normalize
  of Unknown   : ""

#_______________________________________
# Build Target
#_____________________________
proc with *(os :OS; cpu :CPU) :System=
  ## @descr Returns a System object for the given os and cpu.
  result.os  = os
  result.cpu = cpu
#_____________________________
proc getHost *() :System=
  ## @descr Returns the properties of the host, as a System object
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

