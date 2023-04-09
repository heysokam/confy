#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
# confy dependencies
import ../types

var rootDir *:Dir=
  when defined(nimscript):  Dir(".")   # Assumes the confy file is inside root/src/
  else:                     Dir("..")  # Assumes the nimble file is in root/

# Root Folders
var srcDir       *:Dir=  rootDir/"src"
var binDir       *:Dir=  rootDir/"bin"
var libDir       *:Dir=  rootDir/"lib"
var docDir       *:Dir=  rootDir/"doc"
var examplesDir  *:Dir=  rootDir/"examples"
var testsDir     *:Dir=  rootDir/"tests"
# Subfolders
var cacheDir     *:Dir=  binDir/"nimcache"

