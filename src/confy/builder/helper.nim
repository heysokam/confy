#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview Helper code common to all builders.
#____________________________________________________|
# @deps std
import std/os
import std/strformat
import std/sets
# @deps confy
import ../types
import ../cfg
import ../tool/paths
import ../tool/strings
import ../tool/logger


#_________________________________________________
# Compiler Helpers
#_____________________________
proc findExt *(file :DirFile) :string=
  ## Finds the extension of a file that is sent without it.
  ## Walks the file's dir, and matches all entries found against the full path of the given input file.
  ## Raises an exception if the file does have an extension already.
  if file.file.string.splitFile.ext != "": raise newException(IOError, &"Tried to find the extension of a file that already has one.\n  {file.dir/file.file}")
  let filepath = file.dir/file.file
  for found in file.dir.string.walkDir:
    if filepath.string in found.path: return found.path.splitFile.ext
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
  if cfg.verbose and result != Lang.Nim: wrn &"Found Lang.{$result} for DirFile {file}, but confy doesn't understand empty extensions. Must provide one."
#_____________________________
proc getLang *(list :seq[DirFile]) :Lang=
  var langs = initHashSet[Lang]()
  for src in list: langs.incl src.getLang()
  if    Lang.Cpp in langs: result = Lang.Cpp
  elif  Lang.C   in langs: result = Lang.C
  elif  Lang.Nim in langs: result = Lang.Nim
  else: raise newException(CompileError, &"Unimplemented language found in {langs} for files:\n{list}")

