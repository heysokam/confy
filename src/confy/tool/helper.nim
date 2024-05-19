#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/times
# @deps ndk
import nstd/strings
import nstd/shell ; export shell except git, sh
# @deps confy
import ../types
import ../cfg


#_______________________________________
# General Tools
#_____________________________
# Bash
proc sh *(cmd :string; dbg :bool= false) :void=
  ## @descr Runs the given command in a shell (binary).
  if dbg: echo cmd
  if cfg.fakeRun: return
  if os.execShellCmd(cmd) != 0: raise newException(OSError, &"Failed to run shell command:  {cmd}")
proc git *(args :varargs[string,`$`]) :void= sh cfg.gitBin&" "&args.join(" ")
#___________________
# Access time
when not nims:
  from nstd/paths import lastMod, noModSince
  export lastMod, noModSince
#_____________________________
# Files
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
  of MinC      : ".cm"
  of Asm       : ".s"
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

