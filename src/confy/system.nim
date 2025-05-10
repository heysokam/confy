#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`
from std/strutils import join
import std/enumutils
# @deps confy
import ./types/base
import ./types/build
import ./log


#_______________________________________
# @section Command: System Helpers
#_____________________________
func exec *(cmd :Command) :int {.discardable.}=
  log.info "Executing command:\n  ", cmd.args.join(" ")
  return os.execShellCmd cmd.args.join(" ")


#_______________________________________
# @section BuildTarget: System Helpers
#_____________________________
func ext    *(trg :BuildTarget) :PathLike= build.extensions[trg.system.os][trg.kind]
func outDir *(trg :BuildTarget) :PathLike= trg.cfg.dirs.bin/trg.sub
func binary *(trg :BuildTarget) :PathLike= trg.outDir()/trg.trg&trg.ext()
func outBin *(trg :BuildTarget) :PathLike= trg.trg & trg.ext()


#_______________________________________
# @section BuildTarget: Triplet Resolution
#_____________________________
func toNim *(syst :System) :SystemStr=  (os: $syst.os, cpu: $syst.cpu, abi: $syst.abi)
  ## @descr Converts a system object into an (os,cpu,abi) string pair, usable with nimc as --os:OS --cpu:CPU
func toZig *(syst :System) :SystemStr=
  ## @descr Converts a sytem object into an (os,cpu,abi) string pair, usable with `zig cc` as `-target CPU-OS`
  result.os = case syst.os
    of Mac: "macos" # Remove the x from default
    else:   $syst.os
  result.cpu = case syst.cpu
    of x86, x86_64: syst.cpu.symbolName
    of arm64:       "aarch64"
    else:           $syst.cpu
  result.abi = $syst.abi


#_______________________________________
# @section System: Resolution
#_____________________________
proc with *(os :OS; cpu :CPU; abi :ABI= ABI.gnu) :System=
  ## @descr Returns a System object for the given os and cpu.
  result.os  = os
  result.cpu = cpu
#_____________________________
proc host *() :System=
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
  result.abi = ABI.gnu
#_____________________________
proc host *(_:typedesc[System]) :System= system.host()

