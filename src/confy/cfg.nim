#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# confy dependencies
import ./types
import ./auto

#_______________________________________
# confy: Configuration defaults
#___________________
var prefix  *:string=  "confy: "
  ## Prefix that will be added at the start of every command output.
var tab     *:string=  "|    : "
  ## Tab that will be added at the start of every new line in of the same message.
var verbose *:Opt=     off
  ## Output will be fully verbose when active.
var quiet   *:Opt=     off
  ## Output will be formatted in a minimal clean style when active.
var cores   *:float=   0.8
  ## Percentage of total cores to use for compiling.
var file    *:Fil=     "build.nim"
  ## File used for storing the builder config/app.
#___________________
# Debugging
var fakeRun *:Opt=     off
  ## Everything will run normally, but commands will not really be executed.

