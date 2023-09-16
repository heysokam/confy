#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/hashes

const debug * = not (defined(release) or defined(danger)) or defined(debug)

#_________________________________________________
# Package information
#___________________
type Package * = object
  name        *:string
  version     *:string
  author      *:string
  description *:string
  license     *:string

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

