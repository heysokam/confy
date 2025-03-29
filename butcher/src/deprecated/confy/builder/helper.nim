#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview Helper code common to all builders.
#____________________________________________________|
# @deps std
import std/os
import std/sets
import std/enumutils
# @deps ndk
import nstd/strings
import nstd/paths
# @deps confy
import ../types
import ../cfg
import ../tool/logger
# @deps confy.builder.zigcc
import ./zigcc/bin as z
import ./zigcc/zcfg


#_________________________________________________
# Files Helpers
#_____________________________
proc isLib *(file :Fil) :bool=  file.splitFile.ext in [ext.unix.lib, ext.win.lib, ext.mac.lib]
#_____________________________
const validExt = [".cpp", ".cc", ".c", ext.unix.obj, ext.win.obj, ext.mac.obj]
proc isValid *(src :string) :bool=  src.splitFile.ext in validExt
  ## @descr Returns true if the given src file has a valid known file extension.
#_____________________________
proc toLib *(file :Fil; os :OS) :Fil=
  ## @descr Returns the input {@link:arg file} path with shared library file extension based on the input {@link:arg os}.
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.lib
  of   OS.Windows:  file.changeFileExt ext.win.lib
  of   OS.Mac:      file.changeFileExt ext.mac.lib
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc toObj *(file :Fil; os :OS) :Fil=
  ## @descr Returns the input {@link:arg file} path with an object file extension based on the input {@link:arg os}.
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.obj
  of   OS.Windows:  file.changeFileExt ext.win.obj
  of   OS.Mac:      file.changeFileExt ext.mac.obj
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc toBin *(file :Fil; os :OS) :Fil=
  ## @descr Returns the input {@link:arg file} path with a binary file extension based on the input {@link:arg os}.
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.bin
  of   OS.Windows:  file.changeFileExt ext.win.bin
  of   OS.Mac:      file.changeFileExt ext.mac.bin
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc isLib *(trg :Fil) :bool=  trg.splitFile.ext in [ext.unix.lib, ext.win.lib, ext.mac.lib]
  ## @descr Returns true if the target `file` has a known shared library file extension.
#_____________________________
proc isObj *(trg :Fil) :bool=  trg.splitFile.ext in [ext.unix.obj, ext.win.obj, ext.mac.obj]
  ## @descr Returns true if the target `file` has a known object file extension.
#_____________________________
proc isBin *(file :Fil) :bool=
  ## @descr Returns true if the target `file` has a known binary file extension.
  if file.string.isValid: return false  # Never set binary flags for valid compilation unit extensions .o .a .c .cc .cpp
  case file.splitFile.ext
  of ext.unix.bin, ext.win.bin, ext.mac.bin:  return true   # Known binary extensions
  of ext.unix.lib, ext.win.lib, ext.mac.lib:  return false  # dynamic libs are not binaries
  of ext.unix.obj, ext.win.obj:               return false  # objects are not binaries
  else: return true  # Custom extensions (perfectly valid for linux) will be considered binaries.
  # wrn: File extensions for unknown os'es will always return true. Add the os to the `ext` list if this is an issue.
#_____________________________
proc extAR *(os :OS) :string=
  case os
  of OS.Windows: ext.win.ar
  of OS.Linux  : ext.unix.ar
  of OS.Mac    : ext.mac.ar
  else: cerr &"Getting Archive extension of OS.{$os} is not implemented."
func toAR *(file :Fil; os :OS) :Fil= file.changeFileExt(os.extAR())
#_____________________________
proc getCC *(lang :Lang; compiler :Compiler) :string=
  ## @descr Returns the correct command string to build with the given compiler for the given lang.
  case lang
  of Lang.C, Lang.Asm:
    case compiler
    of Zig   : result = zcfg.getRealCC()
    of GCC   : cerr "GCC support has been deprecated. Use ZigCC instead."   # result = ccfg.gcc
    of Clang : cerr "Clang support has been deprecated. Use ZigCC instead." # result = ccfg.clang
    # else: raise newException(CompileError, &"Support for getCC with {lang} and compiler {compiler} is currently not implemented.")
  of Lang.Cpp:
    case compiler
    of Zig   : result = zcfg.getRealCCP()
    of GCC   : cerr "GCC support has been deprecated. Use ZigCC instead"    # result = ccfg.gpp
    of Clang : cerr "Clang support has been deprecated. Use ZigCC instead"  # result = ccfg.clangpp
    # else: raise newException(CompileError, &"Support for getCC with {lang} and compiler {compiler} is currently not implemented.")
  of Lang.Unknown: raise newException(CompileError, &"Tried to getCC with Lang.{lang}. The input lang is either uninitialized, or support for it is not implemented in confy.")
  else: raise newException(CompileError, &"Support for getCC for Lang.{lang} and compiler {compiler} is currently not implemented.")
#_____________________________
proc getCC *(file :DirFile; compiler :Compiler) :string=  file.getLang.getCC(compiler)
  ## @descr Returns the correct command string to build the input file with the given compiler.
  ## @note Its language will be decided by its file extension.
#_____________________________
proc getCC *(list :seq[DirFile]; compiler :Compiler) :string=  list.getLang.getCC(compiler)
  ## @descr Returns the correct command string to build the input list of files with the given compiler.
  ## @notes
  ##  Its language will be decided by its file extension.
  ##  Lang will be cpp first if one of the files has .cpp or .cc extension.
#_____________________________
func toNim *(syst :System) :SystemStr=  (os: $syst.os, cpu: $syst.cpu)
  ## @descr Converts a system object into an (os,cpu) string pair, usable with nimc as --os:OS --cpu:CPU
func toZig *(syst :System) :SystemStr=
  ## @descr Converts a sytem object into an (os,cpu) string pair, usable with `zig cc` as `-target CPU-OS`
  result.os = case syst.os
    of Mac: "macos" # Remove the x from default
    else:   $syst.os
  result.cpu = case syst.cpu
    of x86, x86_64: syst.cpu.symbolName
    of arm64:       "aarch64"
    else:           $syst.cpu

