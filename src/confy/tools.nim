#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
from   std/os import execShellCmd
# confy dependencies
import ./types
from   ./state as c import nil

const GitIgnoreAll = "*\n"  ## Completely hides a folder from git
const GitIgnore    = """
*
!.gitignore
"""  ## Hides all files in a folder, but not the folder

#_____________________________
# General Tools
proc sh *(cmd :string) :void=
  when defined(nimscript): exec cmd
  else:                    discard execShellCmd cmd

#_____________________________
# Dir Setup
proc setup *(trg :Dir) :void=
  for dir in [c.binDir, c.libDir]:  # Setup binDir and libDir
    echo "inside setup: ",$dir
    # Setup binDir
    # let binDir = trg/(dir.splitPath().name)
    # makeDir binDir
    # (binDir/".gitignore").writeFile(GitIgnore)












#_____________________________
# TODO:
proc requires= discard
proc glob= discard
