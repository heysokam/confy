# std dependencies
import std/os
# when not defined(nimscript):
#   import std/paths except `/`
import std/strformat
# import std/cpuinfo
# confy dependencies
import ./types
import ./auto
import ./flags as fl

#_______________________________________
# confy: Configuration defaults
#___________________
# var cores *:int= when nims: 1 else: (0.8 * countProcessors().float).int
# var verbose *:Opt=     off
# var quiet   *:Opt=     on
# var Prefix  *:string=  "confy: "
# var Tab     *:string=  "     : "
# var Cstr    *:string=  "CC"
# var Lstr    *:string=  "LD"
# var zigSystemBin * = on  # default:on
#   ## Uses the System's ZigCC path, without downloading a new version from the web.
#   ## When on : Uses the system's zig like `zig cc file.c
#   ## When off: Runs the zig compiler setup logic and executes the zig compiler like `cfg.zigDir/zig cc file.c`
# var nimUnsafeFunctionPointers * = off
#   ## When active, the flag `-Wno-incompatible-function-pointer-types` will be passed to ZigCC for compiling nim code.
#   ## The correct fix for this unsafety is done in wrapper code. ZigCC is just pointing at incorrectly written code.
#   ## This config option exists just for ergonomics, and the same behavior can be achieved by:
#   ## `someBuildTarget.args = "-Wno-incompatible-function-pointer-types"`


#_________________________________________________
# confy: Debugging
#___________________
var fakeRun  *:Opt=  off
  ## Everything will run normally, but commands will not really be executed.


# #_____________________________
# # Project: Folders
# #___________________
# var rootDir *:Dir=  Dir(".")  # Assumes the nimble/nims file is in root/, and is called from that folder.
# when not defined(nimscript):
#   rootDir = Dir(getAppDir()/"..")  # Assume the builder is inside root/bin/
# # Root Folders
# var srcDir       *:Dir=  rootDir/"src"
# var binDir       *:Dir=  rootDir/"bin"
# var libDir       *:Dir=  rootDir/"lib"
# var docDir       *:Dir=  rootDir/"doc"
# var examplesDir  *:Dir=  rootDir/"examples"
# var testsDir     *:Dir=  rootDir/"tests"
# #___________________
# # Subfolders
# var cacheDir     *:Dir=  binDir/".cache"
# var zigDir       *:Dir=  binDir/"zig"

#_________________________________________________
# Project: Files
#___________________
# var file    *:Fil=  "build.nim"
#   ## File used for storing the builder config/app.
# var db      *:Fil=  binDir/".confy.db"
#   ## File used for storing the builder database.
# var zigJson *:Fil=  binDir/".zig.json"
#   ## Zig download index json file.

#_________________________________________________
# Nim: commands with Sane Defaults
#___________________
# Verbosity --
let switchVerbose   = if cfg.verbose: "--verbose" else: ""
let switchVerbosity = if cfg.verbose: "--verbosity:2" else: ""
# Commands
var nimble * = &"nimble {switchVerbose}"
var nimc   * = &"nim c {switchVerbosity} -d:release"


#_________________________________________________
# Compiler Configuration
#___________________
# Flags
var flagsC * = fl.allC
var flags  * = fl.allPP
