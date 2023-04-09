#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
# confy dependencies
import ../types

var rootDir      *:Dir=  "."  # Assumes the confy file is inside src/
# Root Folders
var srcDir       *:Dir=  rootDir/"src"
var binDir       *:Dir=  rootDir/"bin"
var libDir       *:Dir=  rootDir/"lib"
var docDir       *:Dir=  rootDir/"doc"
var examplesDir  *:Dir=  rootDir/"examples"
var testsDir     *:Dir=  rootDir/"tests"
# Subfolders
var cacheDir     *:Dir=  binDir/"nimcache"

