#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
import confy/RMV/os
import std/strformat
# confy dependencies
import ./types
import ./auto

#_______________________________________
# confy: Configuration defaults
#___________________
var cores   *:float=   0.8
  ## Percentage of total cores to use for compiling.
var verbose *:Opt=     off
  ## Output will be fully verbose when active.
var quiet   *:Opt=     off
  ## Output will be formatted in a minimal clean style when active.
var prefix  *:string=  "confy: "
  ## Prefix that will be added at the start of every command output.
var tab     *:string=  "|    : "
  ## Tab that will be added at the start of every new line in of the same message.
var Cstr    *:string=  "CC"
  ## Prefix used for formatting the quiet output calls to the Compiler.
var Lstr    *:string=  "LD"
  ## Prefix used for formatting the quiet output calls to the Linker.

#_________________________________________________
# confy: Debugging
#___________________
var fakeRun  *:Opt=  off
  ## Everything will run normally, but commands will not really be executed.


#_________________________________________________
# confy: Files
#___________________
var db  *:Fil=  ".confy.db"
  ## File used for storing the builder database.

#_________________________________________________
# Project: Files
#___________________
var file  *:Fil=  "build.nim"
  ## File used for storing the builder config/app.

#_____________________________
# Project: Folders
#___________________
var rootDir *:Dir=
  when defined(nimscript):  Dir(".")   # Assumes the nimble file is in root/
  else:                     Dir("..")  # Assumes the build  file is inside root/src/
# Root Folders
var srcDir       *:Dir=  rootDir/"src"
var binDir       *:Dir=  rootDir/"bin"
var libDir       *:Dir=  rootDir/"lib"
var docDir       *:Dir=  rootDir/"doc"
var examplesDir  *:Dir=  rootDir/"examples"
var testsDir     *:Dir=  rootDir/"tests"
#___________________
# Subfolders
var cacheDir     *:Dir=  binDir/"cache"


#_________________________________________________
# Nim: commands with Sane Defaults
#___________________
# Verbosity --
let switchVerbose   = if cfg.verbose: "--verbose" else: ""
let switchVerbosity = if cfg.verbose: "--verbosity:2" else: ""
# Commands
var nimble * = &"nimble {switchVerbose}"
var nimc   * = &"nim c {switchVerbosity} -d:release --gc:orc"

