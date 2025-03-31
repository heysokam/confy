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
# General
var cores *:int=
  when nims : 1
  else      : (0.8 * cpu.countProcessors().float).int
  ## @descr Total cores to use for compiling.  @default 80% of max)

#___________________
# Formatting
var verbose *:bool=  off
  ## @descr Output will be fully verbose when active.
var quiet   *:bool=  on and not verbose
  ## @descr Output will be formatted in a minimal clean style when active.
var prefix  *:string=  "confy: "
  ## @descr Prefix that will be added at the start of every command output.
var tab     *:string=  "     : "
  ## @descr Tab that will be added at the start of every new line in of the same message.

#___________________
# Nim
var nim * = (
  cc        : "nim",
  systemBin : on,
  backend   : "c",
  url       : "https://github.com/nim-lang/Nim",
  vers      : "version-2-0",
  unsafe    : (
    functionPointers : off,
    ) # << cfg.nim.unsafe ( ... )
  ) # << cfg.nim ( ... )

#___________________
# MinC
var minc * = (
  cc        : "minc",
  systemBin : off,
  url       : "https://github.com/heysokam/minc",
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

#___________________
# Shell Tools
var gitBin * = "git"
  ## @descr Binary to call for running `git` tasks.

#_________________________________________________
# confy: Debugging
#___________________
var fakeRun *:bool=  off
  ## @descr Everything will run normally, but commands will not really be executed.


#_____________________________
# Project: Folders
#___________________
var rootDir *:Dir=
  when nims : Dir(".")               # Assumes the nimble/nims file is in root/, and is called from that folder.
  else      : Dir(getAppDir()/"..")  # Assume the builder is inside root/bin/
#___________________
# Root Folders
var srcSub       *:Dir=  Dir "src"
var srcDir       *:Dir=  rootDir/srcSub
var binSub       *:Dir=  Dir "bin"
var binDir       *:Dir=  rootDir/binSub
var libDir       *:Dir=  rootDir/"lib"
var docSub       *:Dir=  Dir "doc"
var docDir       *:Dir=  rootDir/docSub
var examplesDir  *:Dir=  rootDir/"examples"
var testsDir     *:Dir=  rootDir/"tests"
#___________________
# Subfolders
var cacheDir     *:Dir=  binDir/".cache"
var zigDir       *:Dir=  binDir/".zig"
var nimDir       *:Dir=  binDir/".nim"
var mincDir      *:Dir=  binDir/".minc"

#_________________________________________________
# Project: Files
#___________________
var file    *:Fil=  "build.nim".Fil
  ## File used for storing the builder config/app.
var zigJson *:Fil=  zigDir/"versions.json"
  ## Zig download index json file.


#_________________________________________________
# Compiler Configuration
#___________________
# Flags
proc flags *(lang :Lang) :Flags=
  case lang
  of C   : return fl.all(C)
  of Cpp : return fl.all(Cpp)
  else: quit( "Tried to get the flags of a lang that doesn't have any." )
#___________________
var flagsC   *:Flags= cfg.flags(C)
var flagsCpp *:Flags= cfg.flags(Cpp)

