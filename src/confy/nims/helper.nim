#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Nimscript : Helpers  |
#______________________|
import ./guard
# std dependencies
import std/os
import std/strformat
import std/strutils
import std/sequtils
# nims dependencies
import ./confy


#___________________
proc cliParams *() :seq[string]=
  ## Returns the list of Command Line Parameters passed to the script.
  ## TODO: Fix the issues. Why is this not getting all of the items??
  var start = true
  for id in 0..<paramCount(): 
    let curr = paramStr( id )
    if projectName() in curr: start = false
    if start: continue
    result.add paramStr( id )
var cliOpts * = cliParams().filterIt( it.startsWith('-') )
  ## List of command line options passed to the nims script.
var cliArgs * = cliParams().filterIt( not it.startsWith('-') )
  ## List of command line arguments passed to the nims script.


#___________________
let nimcr * = &"nim c -r --outdir:{cfg.binDir}"
  ## Compile and run, outputting to binDir.
proc runFile *(dir, file, args :string) :void=  exec &"{nimcr} {dir/file} {args}"
  ## Runs file from the given dir, using the nimcr command.
proc build *(args :string) :void=  runFile( cfg.srcDir, cfg.file, args )
  ## Orders to build the project, passing the given args to the builder app.
proc sh *(cmd :string; dir :string= ".") :void=
  ## Runs the given command and a shell.
  if not quiet: log &"Running {cmd} from {dir} ..."
  withDir dir: exec cmd
  if not quiet: log &"Done running {cmd}."

