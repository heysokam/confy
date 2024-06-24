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
import nstd/errors
# @deps confy
import ../types as confy
import ../cfg
import ../tool/logger
# @deps confy.builder.zigcc
import ./zigcc/bin as z
import ./zigcc/zcfg


#_________________________________________________
# Compiler Helpers
#_____________________________
proc exists *(c :Compiler) :bool=
  ## @descr Returns true if the given compiler exists in the system.
  case c
  of Zig   : result = z.initOrExists()
  of GCC   : cerr "GCC has been deprecated"   # result = gorgeEx(ccfg.gcc   & " --version").exitCode == 0
  of Clang : cerr "Clang has been deprecated" # result = gorgeEx(ccfg.clang & " --version").exitCode == 0
  # else:     result = false
#_____________________________
proc findExt *(file :Fil) :string=
  ## @descr
  ##  Finds the extension of a file that is sent without it.
  ##  Walks the file's dir, and matches all entries found against the full path of the given input file.
  ## @raises IOError if the file does have an extension already.
  if file.ext != "": IOError.trigger &"Tried to find the extension of a file that already has one.\n  {file}"
  let dir = Path.new(file.dir)
  for found in dir.walk:
    if found.isDir: continue
    if file.path in found.path: return found.ext
  IOError.trigger &"Failed to find the extension of file:\n  {file}"
#_____________________________
func getLangFromExt (ext :string) :Lang=
  ## @descr Returns the language of the given input extension. An empty extension will return Unknown lang.
  ## @note Use `DirFile.findLangExt()` to find the extension when the file exists and its sent without it.
  case ext
  of ".c"          : result = Lang.C
  of ".cpp", ".cc" : result = Lang.Cpp
  of ".nim"        : result = Lang.Nim
  of ".cm"         : result = Lang.MinC
  of ".s"          : result = Lang.Asm
  else             : result = Lang.Unknown
#_____________________________
proc getLang *(file :Fil) :Lang=
  ## @descr Returns the language of the given input file, based on its extension.
  if file.ext != "": return getLangFromExt( file.ext )
  result = getLangFromExt( file.findExt() )
  if cfg.verbose and result != Lang.Nim: wrn &"Found Lang.{$result} for Path {file}, but confy doesn't understand empty extensions. Must provide one."
#_____________________________
proc getLang *(list :PathList) :Lang=
  ## @descr Returns the language of the given input list of files, based on their extension.
  var langs = initHashSet[Lang]()
  for src in list: langs.incl src.getLang()
  if    Lang.Nim  in langs: result = Lang.Nim
  elif  Lang.MinC in langs: result = Lang.MinC
  elif  Lang.Cpp  in langs: result = Lang.Cpp
  elif  Lang.C    in langs: result = Lang.C
  elif  Lang.Asm  in langs: result = Lang.Asm
  else: raise newException(CompileError, &"Unimplemented language found in {langs} for files:\n{list}")

#_________________________________________________
# Files Helpers
#_____________________________
proc isLib *(file :Fil) :bool=  file.ext in [confy.ext.unix.lib, confy.ext.win.lib, confy.ext.mac.lib]
#_____________________________
const validExt = [".cpp", ".cc", ".c", confy.ext.unix.obj, confy.ext.win.obj, confy.ext.mac.obj]
proc isValid *(src :Fil) :bool=  src.ext in validExt
  ## @descr Returns true if the given src file has a valid known file extension.
#_____________________________
proc toLib *(file :Fil; os :OS) :Fil=
  ## @descr Returns the input {@link:arg file} path with shared library file extension based on the input {@link:arg os}.
  case os
  of   OS.Linux:    file.changeExt confy.ext.unix.lib
  of   OS.Windows:  file.changeExt confy.ext.win.lib
  of   OS.Mac:      file.changeExt confy.ext.mac.lib
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc toObj *(file :Fil; os :OS) :Fil=
  ## @descr Returns the input {@link:arg file} path with an object file extension based on the input {@link:arg os}.
  case os
  of   OS.Linux:    file.changeExt confy.ext.unix.obj
  of   OS.Windows:  file.changeExt confy.ext.win.obj
  of   OS.Mac:      file.changeExt confy.ext.mac.obj
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc toBin *(file :Fil; os :OS) :Fil=
  ## @descr Returns the input {@link:arg file} path with a binary file extension based on the input {@link:arg os}.
  case os
  of   OS.Linux:    file.changeExt confy.ext.unix.bin
  of   OS.Windows:  file.changeExt confy.ext.win.bin
  of   OS.Mac:      file.changeExt confy.ext.mac.bin
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc isLib *(trg :Fil) :bool=  trg.ext in [confy.ext.unix.lib, confy.ext.win.lib, confy.ext.mac.lib]
  ## @descr Returns true if the target `file` has a known shared library file extension.
#_____________________________
proc isObj *(trg :Fil) :bool=  trg.ext in [confy.ext.unix.obj, confy.ext.win.obj, confy.ext.mac.obj]
  ## @descr Returns true if the target `file` has a known object file extension.
#_____________________________
proc isBin *(file :Fil) :bool=
  ## @descr Returns true if the target `file` has a known binary file extension.
  if file.isValid: return false  # Never set binary flags for valid compilation unit extensions .o .a .c .cc .cpp
  case file.ext
  of confy.ext.unix.bin, confy.ext.win.bin, confy.ext.mac.bin:  return true   # Known binary extensions
  of confy.ext.unix.lib, confy.ext.win.lib, confy.ext.mac.lib:  return false  # dynamic libs are not binaries
  of confy.ext.unix.obj, confy.ext.win.obj:                     return false  # objects are not binaries
  else: return true  # Custom extensions (perfectly valid for linux) will be considered binaries.
  # wrn: File extensions for unknown os'es will always return true. Add the os to the `ext` list if this is an issue.
#_____________________________
proc extAR *(os :OS) :string=
  case os
  of OS.Windows: confy.ext.win.ar
  of OS.Linux  : confy.ext.unix.ar
  of OS.Mac    : confy.ext.mac.ar
  else: cerr &"Getting Archive extension of OS.{$os} is not implemented."
func toAR *(file :Fil; os :OS) :Fil= file.changeExt(os.extAR())
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
proc getCC *(file :Fil; compiler :Compiler) :string=  file.getLang.getCC(compiler)
  ## @descr Returns the correct command string to build the input file with the given compiler.
  ## @note Its language will be decided by its file extension.
#_____________________________
proc getCC *(list :PathList; compiler :Compiler) :string=  list.getLang.getCC(compiler)
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

