#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
import confy/RMV/osdirs
import std/strutils
import std/strformat
# confy dependencies
import ./types
import ./tools/git
from   ./state as c import nil
import ./logger


#_____________________________
# Dir Setup
proc setup *(trg :Dir) :void=
  for dir in [c.binDir, c.libDir]:  # Setup binDir and libDir
    log &"inside setup: {dir}"
    # let binDir = trg/(dir.splitPath().name)
    # makeDir binDir
    # (binDir/".gitignore").writeFile(git.ignore)

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


