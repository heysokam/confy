#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Helper code common to all builders  |
#_____________________________________|
# std dependencies
import std/os
import std/strutils
import std/strformat
import std/sets
import std/enumutils
# confy dependencies
import ../types
import ../cfg
import ../tool/logger
# builder dependencies
from   ./zig/bin as z import nil
import ./zig/zcfg
import ./C/ccfg


#_________________________________________________
# Files Helpers
#_____________________________
proc isLib *(file :Fil) :bool=  file.splitFile.ext in [ext.unix.lib, ext.win.lib, ext.mac.lib]
#_____________________________
const validExt = [".cpp", ".cc", ".c", ext.unix.obj, ext.win.obj, ext.mac.obj]
proc isValid *(src :string) :bool=  src.splitFile.ext in validExt
  ## Returns true if the given src file has a valid known file extension.
#_____________________________
proc toLib *(file :Fil; os :OS) :Fil=
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.lib
  of   OS.Windows:  file.changeFileExt ext.win.lib
  of   OS.Mac:      file.changeFileExt ext.mac.lib
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc toObj *(file :Fil; os :OS) :Fil=
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.obj
  of   OS.Windows:  file.changeFileExt ext.win.obj
  of   OS.Mac:      file.changeFileExt ext.mac.obj
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc isObj *(trg :Fil) :bool=  trg.splitFile.ext in [ext.unix.obj, ext.win.obj, ext.mac.obj]
  ## Returns true if the `trg` file is already a compiled object.
#_____________________________
proc isBin *(file :Fil) :bool= 
  ## Returns true if the target `file` is considered to have a known binary file extension.
  if file.isValid: return false  # Never set binary flags for valid compilation unit extensions .o .a .c .cc .cpp
  case file.splitFile.ext
  of ext.unix.bin, ext.win.bin, ext.mac.bin:  return true   # Known binary extensions
  of ext.unix.lib, ext.win.lib, ext.mac.lib:  return false  # dynamic libs are not binaries
  of ext.unix.obj, ext.win.obj:               return false  # objects are not binaries
  else: return true  # Custom extensions (perfectly valid for linux) will be considered binaries.
  # wrn: File extensions for unknown os'es will always return true. Add the os to the `ext` list if this is an issue.


#_________________________________________________
# Compiler Helpers
#_____________________________
proc exists *(c :Compiler) :bool=
  ## Returns true if the given compiler exists in the system.
  case c
  of Zig:   result = z.initOrExists()
  of GCC:   result = gorgeEx(ccfg.gcc   & " --version").exitCode == 0
  of Clang: result = gorgeEx(ccfg.clang & " --version").exitCode == 0
  # else:     result = false
#_____________________________
proc findExt *(file :DirFile) :string=
  ## Finds the extension of a file that is sent without it.
  ## Walks the file's dir, and matches all entries found against the full path of the given input file.
  ## Raises an exception if the file does have an extension already.
  if file.file.splitFile.ext != "": raise newException(IOError, &"Tried to find the extension of a file that already has one.\n  {file.dir/file.file}")
  let filepath = file.dir/file.file
  for found in file.dir.walkDir:
    if filepath in found.path: return found.path.splitFile.ext
  raise newException(IOError, &"Failed to find the extension of file:\n  {file.dir/file.file}")
#_____________________________
func getLangFromExt (ext :string) :Lang=
  ## Returns the language of the given input extension. An empty extension will return Unknown lang.
  ## Use `DirFile.findLangExt()` to find the extension when the file exists and its sent without it.
  case ext
  of ".c"          : result = Lang.C
  of ".cpp", ".cc" : result = Lang.Cpp
  of ".nim"        : result = Lang.Nim
  else             : result = Lang.Unknown
#_____________________________
proc getLang *(file :DirFile) :Lang=
  ## Returns the language of the given input file, based on its extension.
  let ext = file.file.splitFile.ext
  if ext != "": return getLangFromExt( ext )
  result = getLangFromExt( file.findExt() )
  if cfg.verbose: wrn &"Found Lang.{$result} for DirFile {file}, but confy doesn't understand empty extensions. Must provide one."
#_____________________________
proc getLang *(list :seq[DirFile]) :Lang=
  var langs = initHashSet[Lang]()
  for src in list: langs.incl src.getLang()
  if    Lang.Cpp in langs: result = Lang.Cpp
  elif  Lang.C   in langs: result = Lang.C
  elif  Lang.Nim in langs: result = Lang.Nim
  else: raise newException(CompileError, &"Unimplemented language found in {langs} for files:\n{list}")
#_____________________________
proc getCC *(lang :Lang; compiler :Compiler) :string=
  ## Returns the correct command string to build with the given compiler for the given lang.
  case lang 
  of Lang.C:
    case compiler
    of Zig:   result = zcfg.getRealCC()
    of GCC:   result = ccfg.gcc
    of Clang: result = ccfg.clang
    # else: raise newException(CompileError, &"Support for getCC with {lang} and compiler {compiler} is currently not implemented.")
  of Lang.Cpp:
    case compiler
    of Zig:   result = zcfg.getRealCCP()
    of GCC:   result = ccfg.gpp
    of Clang: result = ccfg.clangpp
    # else: raise newException(CompileError, &"Support for getCC with {lang} and compiler {compiler} is currently not implemented.")
  of Lang.Unknown: raise newException(CompileError, &"Tried to getCC with Lang.{lang}. The input lang is either uninitialized, or support for it is not implemented in confy.")
  else: raise newException(CompileError, &"Support for getCC with compiler {compiler} is currently not implemented.")
#_____________________________
proc getCC *(file :DirFile; compiler :Compiler) :string=  file.getLang.getCC(compiler)
  ## Returns the correct command string to build the input file with the given compiler.
  ## Its language will be decided by its file extension.
#_____________________________
proc getCC *(list :seq[DirFile]; compiler :Compiler) :string=  list.getLang.getCC(compiler)
  ## Returns the correct command string to build the input list of files with the given compiler.
  ## Its language will be decided by its file extension.
  ## Lang will be cpp first if one of the files has .cpp or .cc extension.
#_____________________________
func toNim *(syst :System) :SystemStr=  (os: $syst.os, cpu: $syst.cpu)
  ## Converts a system object into an (os,cpu) string pair, usable with nimc as --os:OS --cpu:CPU
func toZig *(syst :System) :SystemStr=
  ## Converts a sytem object into an (os,cpu) string pair, usable with `zig cc` as `-target CPU-OS`
  result.os = case syst.os
    of Mac: "macos" # Remove the x from default
    else:   $syst.os
  result.cpu = case syst.cpu
    of x86, x86_64: syst.cpu.symbolName
    of arm64:       "aarch64"
    else:           $syst.cpu

