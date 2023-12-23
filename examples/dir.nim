#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview
##  Folders configuration for the examples buildsystem.
#_______________________________________________________|
# @deps std
import std/os

# General
const thisDir :string= currentSourcePath().parentDir()
const confy  *:string= thisDir/".."/"src"
# Languages
const C      *:string= thisDir/"C"
const cpp    *:string= thisDir/"cpp"
const nim    *:string= thisDir/"nim"
# Examples   @note Suffixes for all langs
const hello  *:string= "hello"
const cross  *:string= "cross"
const full   *:string= "full"
