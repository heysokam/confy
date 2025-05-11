#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`, splitFile
from std/strutils import join
from std/strformat import fmt
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
# TODO:
# proc findExt *(file :PathLike) :string=
#   ## @descr
#   ##  Finds the extension of a file that is sent without it.
#   ##  Walks the file's dir, and matches all entries found against the full path of the given input file.
#   ## @raises IOError if the file does have an extension already.
#   if file.splitFile.ext != "": raise newException(IOError, fmt"Tried to find the extension of a file that already has one.\n  {file}")
#   let filepath = file
#   for found in file.dir.string.walkDir:
#     if found.kind == pcDir: continue
#     if filepath.string in found.path: return found.path.splitFile.ext
#   raise newException(IOError, &"Failed to find the extension of file:\n  {file.dir/file.file}")


#_______________________________________
# @section System: Resolution
#_____________________________
proc with *(os :OS; cpu :CPU; abi :ABI= ABI.gnu) :System=
  ## @descr Returns a System object for the given os and cpu.
  result.os  = os
  result.cpu = cpu
  result.abi = abi
#___________________
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
#___________________
proc host *(_:typedesc[System]) :System= systm.host()
#___________________
proc cross *(syst :System) :bool= syst != systm.host()



#_______________________________________
# @section BuildTarget: Triplet Resolution
#_____________________________
func toNim *(syst :System) :SystemStr=  (os: $syst.os, cpu: $syst.cpu, abi: "")
  ## @descr Converts a system object into an (os,cpu) string pair, usable with nimc as --os:OS --cpu:CPU
#___________________
func toZig *(os :OS) :string=
  case os
  of UndefinedOS : systm.host().os.toZig()
  of Mac         : "macos" # Remove the x from default
  else           : $os
#___________________
func toZig *(cpu :CPU) :string=
  case cpu
  of UndefinedCPU : systm.host().cpu.toZig()
  of x86, x86_64  : cpu.symbolName
  of arm64        : "aarch64"
  else            : $cpu
#___________________
func toZig *(syst :System) :SystemStr=
  ## @descr Converts a sytem object into an (os,cpu,abi) string pair, usable with `zig cc` as `-target CPU-OS`
  ## @note `result.abi` will be "" when {@arg syst}.abi is {@link ABI}.none
  result.os  = syst.os.toZig()
  result.cpu = syst.cpu.toZig()
  if syst.abi != ABI.none: result.abi = $syst.abi
#___________________
func tag *(syst :SystemStr) :string=
  ## @descr Returns the Zig triplet tag (-target ???) for the given {@link SystemStr}
  result = fmt"{syst.cpu}-{syst.os}"
  if syst.abi != "none" and syst.abi != "":
    result.add fmt"-{syst.abi}"
#___________________
func toZigTag *(syst :System) :string=
  result.add "-target "
  result.add syst.toZig().tag()


