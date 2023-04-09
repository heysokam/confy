#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# confy dependencies
import ./types

#_______________________________________
# confy: Configuration defaults
#___________________
var prefix  *:string=  "confy: "
  ## Prefix that will be added at the start of every command output.
var verbose *:Opt=     false
  ## Output will be fully verbose when active
var cores   *:float=   0.8
  ## Percentage of total cores to use for compiling

