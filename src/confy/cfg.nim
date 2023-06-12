#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os except `/`
when not defined(nimscript):
  import std/paths
import std/strformat
import std/cpuinfo
# confy dependencies
import ./types
import ./auto
import ./flags as fl

#_______________________________________
# confy: Configuration defaults
#___________________
when defined(nimscript):
  var cores *:int= 1
else:
  var cores *:int= (0.8 * countProcessors().float).int
  ## Total cores to use for compiling.  (default = 80% of max)
var verbose *:Opt=     off
  ## Output will be fully verbose when active.
var quiet   *:Opt=     on
  ## Output will be formatted in a minimal clean style when active.
var prefix  *:string=  "confy: "
  ## Prefix that will be added at the start of every command output.
var tab     *:string=  "     : "
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


#_____________________________
# Project: Folders
#___________________
var rootDir *:Dir=  Dir(".")  # Assumes the nims  file is in root/, and is called from that folder.
when not defined(nimscript):
  rootDir = Dir(getAppDir()/"..")  # Assume the builder is inside root/bin/
# Root Folders
var srcDir       *:Dir=  rootDir/"src"
var binDir       *:Dir=  rootDir/"bin"
var libDir       *:Dir=  rootDir/"lib"
var docDir       *:Dir=  rootDir/"doc"
var examplesDir  *:Dir=  rootDir/"examples"
var testsDir     *:Dir=  rootDir/"tests"
#___________________
# Subfolders
var cacheDir     *:Dir=  binDir/".cache"
var zigDir       *:Dir=  binDir/"zig"

#_________________________________________________
# Project: Files
#___________________
var file    *:Fil=  "build.nim"
  ## File used for storing the builder config/app.
var db      *:Fil=  binDir/".confy.db"
  ## File used for storing the builder database.
var zigJson *:Fil=  binDir/".zig.json"
  ## Zig download index json file.

#_________________________________________________
# Nim: commands with Sane Defaults
#___________________
# Verbosity --
let switchVerbose   = if cfg.verbose: "--verbose" else: ""
let switchVerbosity = if cfg.verbose: "--verbosity:2" else: ""
# Commands
var nimble * = &"nimble {switchVerbose}"
var nimc   * = &"nim c {switchVerbosity} -d:release --mm:orc"


#_________________________________________________
# Compiler Flags
#___________________
var flagsC * = fl.allC
var flags  * = fl.allPP

