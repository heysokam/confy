#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# nims dependencies
import ./guard

type Cfg * = object  ## Storage of compiling profile options
  nimc  *:string     ## Options to pass to the compiler itself
  opts  *:string     ## Options to pass to the binary when its run
  bin   *:string     ## Output name of the binary file
  bld   *:string     ## Command to build the files needed for the task
  run   *:string     ## Command to run in the task
  src   *:string     ## Source code file to compile

