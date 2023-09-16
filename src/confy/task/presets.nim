#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/strutils
# confy dependencies
import ../tool/logger
import ../cfg
# task dependencies
import ./deps
import ./list
import ./state
import ./todo

#_____________________________
# Preset Tasks
#___________________
proc docgen *() :void=
  ## Internal keyword
  ## Generates the package documentation using Nim's docgen tools.
  ## TODO: Remove hardcoded repo user
  info "Starting docgen..."
  discard os.execShellCmd &"nim doc --project --index:on --git.url:https://github.com/heysokam/{package.name} --outdir:doc/gen src/{package.name}.nim"
  info "Done with docgen."
#___________________
proc tests *()=
  ## Internal keyword
  ## Builds and runs all tests in the testsDir folder.
  for file in cfg.testsDir.walkDir():
    if file.path.lastPathPart.startsWith('t'):
      try: runFile file.path
      except: echo &" └─ Failed to run one of the tests from  {file}"
#___________________
proc push *()=
  ## Internal task
  ## Pushes the git repository, and orders to create a new git tag for the package, using the latest version.
  ## Does nothing when local and remote versions are the same.
  deps.require "https://github.com/beef331/graffiti.git"
  discard os.execShellCmd "git push"  # Requires local auth
  discard os.execShellCmd &"graffiti ./{package.name}.nimble"
#___________________
# Add them to the internal list
task "docgen" , "Generates the package documentation using Nim's docgen tools.", docgen
task "tests"  , "Builds and runs all tests in the testsDir folder.", tests
task "push"   , "Pushes the git repository, and orders to create a new git tag for the package, using the latest version.", push

