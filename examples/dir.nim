# @deps std
import std/os
# General
const this   :string= currentSourcePath().parentDir()
# Languages
const C     *:string= this/"C"
const cpp   *:string= this/"cpp"
const nim   *:string= this/"nim"
# Examples   @note Suffixes for all langs
const hello *:string= "hello"
const cross *:string= "cross"
const full  *:string= "full"
