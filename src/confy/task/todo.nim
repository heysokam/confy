#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
# confy dependencies
import ../tool/opts
import ../tool/logger
import ../cfg
import ./base


#_________________________________________________
# Build Helpers
#_____________________________
# TODO
const vlevel = when debug: 2 else: 1
let nimcr = &"nim c -r --verbosity:{vlevel} --outdir:{cfg.binDir}"
  ## Compile and run, outputting to binDir
proc runFile *(file, dir, args :string) :void=  discard os.execShellCmd &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command, and passing it the given args
proc runFile *(file :string) :void=  file.runFile( "", "" )
  ## Runs file using the nimcr command



#_________________________________________________
# Task: any
#___________________
# TODO
type Cfg = object # Storage of compiling profile options
  nimc  :string   # Options to pass to the compiler itself
  opts  :string   # Options to pass to the binary when its run
  bin   :string   # Output name of the binary file
  bld   :string   # Command to build the files needed for the task
  run   :string   # Command to run in the task
  src   :string   # Source code file to compile
#___________________
var anyc :Cfg
let anyArgs = getArgs()
anyc.src = if anyArgs.len > 2: anyArgs[2] else: ""
let name = anyc.src.splitFile.name
anyc.bin = cfg.binDir/name
anyc.run = &"{anyc.bin} {anyc.opts}"
anyc.bld = &"nim c {anyc.nimc} -o:{anyc.bin} {anyc.src}"
#____________________________________________
proc beforeAny () :void=
  log " Building  ",anyc.src,"  file into   ",cfg.binDir.string
proc afterAny  () :void=
  log "Done building. Running...  ",anyc.run
  discard execShellCmd anyc.run
  anyc.bin.removeFile  # Remove the binary output file when done
#____________________________________________
proc any *() :void=
  ## Builds any given source code file into binDir. Useful for testing/linting individual files.
  beforeAny()
  if anyArgs.len < 2: cerr "The any command expects a source file as its first argument after they `any` keyword."
  discard execShellCmd anyc.bld
  afterAny()

