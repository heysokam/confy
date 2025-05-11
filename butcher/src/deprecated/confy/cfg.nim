#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os except getAppDir
import std/cpuinfo as cpu
# @deps ndk
import nstd/paths
# @deps confy
import ./types
import ./flags as fl


#___________________
# Nim
var nim * = (
  url : "https://github.com/nim-lang/Nim",
  ) # << cfg.nim ( ... )

#___________________
# MinC
var minc * = (
  url : "https://github.com/heysokam/minc",
  ) # << cfg.minc ( ... )
  ## @field cc
  ##  Selects the binary that confy will call when it needs to run `minc [options]`
  ##  Can be a binary in PATH, or an absolute or relative path
  ## @field systemBin
  ##  Uses the System's MinC path, without downloading a new version from the web.
  ##  @default:off
  ##  @when on : Uses the system's minc like `minc c file.cm`
  ##  @when off: Runs the minc compiler setup logic and executes the minc compiler like `cfg.mincDir/bin/minc c file.cm`
  ## @field url
  ##  Link to the MinC repository that will be used for initializing a local-installation of the compiler.


#_____________________________
# Project: Folders
#___________________
# Root Folders
var docSub       *:Dir=  Dir "doc"
var docDir       *:Dir=  rootDir/docSub
var examplesDir  *:Dir=  rootDir/"examples"

