#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/hashes

#_________________________________________________
# Tasks List
#___________________
type TaskCallback * = proc():void
type Task * = object
  name  *:string
  descr *:string
  call  *:TaskCallback
proc hash *(obj :Task) :Hash=  hash(obj.name)
proc `==` *(a,b :Task) :bool=  a.name == b.name

