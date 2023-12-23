#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview
##  Types for configuring the examples folder.
##  None of this is needed for a real project.
#______________________________________________|
# @deps std
import std/[ os,strformat,strutils ]
# @deps .
import ./dir

#_______________________________________
# General
#___________________
const Prefix {.strdefine.}= "confy.examples: "
#___________________
proc sh *(cmd :string; dir :string= ".") :void= 
  echo Prefix&"Running command from $1:\n  $2" % [dir, cmd];
  withDir dir: exec cmd
#___________________
proc push *():void=
  sh "git push"  # Requires local auth
  sh &"graffiti ./{packageName}.nimble"

#_______________________________________
# Examples: Config
#___________________
type Example = object
  ## @descr Collection of configuration options for building a specific example.
  dir  *:string
  cmd  *:string
#___________________
type  LangID * = enum C, Cpp, Nim
const LangIDs :set[LangID]= {C,Cpp,Nim}
#___________________
type Lang * = object
  ## @descr Collection of configuration options for building the examples of a specific lang.
  ## @field hello Minimal hello world example for the target language.
  ## @field cross Cross compilation of the minimal hello world example for the target language.
  ## @field full  Showcase example for confy. Fully explicity configuration of the minimal hello world example for the target language
  id     *:LangID
  hello  *:Example
  cross  *:Example
  full   *:Example
#___________________
func getConfig (lang :LangID) :Lang=
  ## @descr Returns the configuration options for building the examples for the specified `lang` id.
  if lang notin LangIDs: raise newException(IOError, "Asked for the configuration of the examples for an unknown lang.")
  var root :string= case lang
    of C   : dir.C
    of Cpp : dir.cpp
    of Nim : dir.nim
  var cmd :string= case lang
    of Nim : "nimble run"
    else   : "nim --verbosity:3 --noNimblePath --path:$1 confy.nims" % [dir.confy]
  Lang(id: lang,
    hello: Example(dir: root/dir.hello, cmd: cmd),
    cross: Example(dir: root/dir.cross, cmd: cmd),
    full : Example(dir: root/dir.full , cmd: cmd),
    ) # << Lang(id: lang, ... )

#_______________________________________
# Examples: Build
#___________________
template build *(lang :Lang; example :untyped) :void=
  sh lang.`example`.cmd, lang.`example`.dir

proc buildAll *(lang :LangID) :void=
  let cfg :Lang= lang.getConfig()
  cfg.build( hello )
  # cfg.build( cross )
  # cfg.build( full  )

proc buildAll *() :void=
  for lang in LangID: lang.buildAll()
