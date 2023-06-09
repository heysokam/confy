#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/paths ; export paths
import std/dirs
import std/strutils
import std/strformat
# confy dependencies
import ./types
import ./tool/git
import ./tool/logger
import ./cfg as c

#_____________________________
# Dir Helpers
proc chgDir *(file :Fil; dirFrom, dirTo :Dir) :Fil=  file.replace(dirFrom, dirTo)
  ## Changes the given `file` path from `dirFrom` to `dirTo`.

#_____________________________
# Dir Setup
proc setup *(trg :Dir) :void=
  if not quiet: log0 &"Setting up folder {trg}"
  let curr = if not trg.isAbsolute: c.binDir/trg else: trg
  block:
    if curr.dirExists and "bin" notin curr:
      if not quiet: log1 &"Folder {curr.absolutePath} already exists. Ignoring its setup."
      break
    createDir curr
  if   c.binDir in curr:  (curr/".gitignore").writeFile(git.ignore)
  # elif c.libDir in curr:  (curr/".gitignore").writeFile(git.ignoreAll)

#_____________________________
# Glob Path Creation
proc glob *(dir :Dir; ext :string= ".c"; rec :bool= false) :seq[Fil]=
  ## Globs every file in the given folder that has the given ext.
  ## `ext` the extension to search for. Default: `.c`
  ## `rec` recursive search in all folders and subfolders when true. Default: `false`
  if rec:
    for file in dir.string.walkDirRec:
      if file.endsWith(ext): result.add file.Fil
  else:
    for file in dir.string.walkDir:
      if file.path.endsWith(ext): result.add file.path.Fil


