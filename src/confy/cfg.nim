#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/cpuinfo as cpu
# @deps confy
import ./types
import ./tool/paths
import ./flags as fl

#___________________
# General
var cores *:int=
  when nims : 1
  else      : (0.8 * cpu.countProcessors().float).int
  ## @descr Total cores to use for compiling.  @default 80% of max)
#___________________
# Formatting
var verbose *:bool=  when debug: on else: off
  ## Output will be fully verbose when active.
var quiet   *:bool=  on and not verbose
  ## Output will be formatted in a minimal clean style when active.
var prefix  *:string=  "confy: "
  ## Prefix that will be added at the start of every command output.
var tab     *:string=  "     : "
  ## Tab that will be added at the start of every new line in of the same message.
var Cstr    *:string=  "CC"
  ## Prefix used for formatting the quiet output calls to the Compiler.
var Lstr    *:string=  "LD"
  ## Prefix used for formatting the quiet output calls to the Linker.
#___________________
# ZigCC
var zigcc * = (
  systemBin : off,  # default:off
  ) # << cfg.zigcc ( ... )
  ## @field systemBin
  ##  Uses the System's ZigCC path, without downloading a new version from the web.
  ##  @when on : Uses the system's zig like `zig cc file.c
  ##  @when off: Runs the zig compiler setup logic and executes the zig compiler like `cfg.zigDir/zig cc file.c`
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
  ## @field cc
  ##  Selects the binary that confy will call when it needs to run `nim [options]`
  ##  Can be a binary in PATH, or an absolute or relative path
  ##  @default "nim" Relies on nim being installed on PATH
  ## @field systemBin
  ##  @default:on Avoids confusion for nim users.
  ##   They will expect it `on` because both the nim compiler and nimble work that way.
  ## @field backend
  ##   Selects the backend that the nim compiler will use to build the project.
  ##   @note Only applies to the project files. The builder app always compiles with the `nim c` backend.
  ## @field url
  ##  Link to the Nim repository that will be used for initializing a local-installation of the compiler.
  ## @field vers
  ##  Name of the branch (aka version) that will be used when cloning the Nim repository for local-installation of the compiler.
  ## @field unsafe.functionPointers
  ##  When active, the flag `-Wno-incompatible-function-pointer-types` will be passed to ZigCC for compiling nim code.
  ##  The correct fix for this unsafety is done in wrapper code. ZigCC is just pointing at incorrectly written code.
  ##  This config option exists just for ergonomics, and the same behavior can be achieved by:
  ##  `someBuildTarget.args = "-Wno-incompatible-function-pointer-types"`

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
var binDir       *:Dir=  rootDir/"bin"
var libDir       *:Dir=  rootDir/"lib"
var docDir       *:Dir=  rootDir/"doc"
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

