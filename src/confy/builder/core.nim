#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/strformat
import std/sets
# @deps confy
import ../types
import ../cfg
import ../info
import ../dirs
import ../tool/logger
import ../tool/helper as t
import ../tool/paths
import ../tool/strings
import ../task/state
# @deps confy.builder
import ./helper
import ./zigcc as c
import ./zigcc as cpp
import ./nim as nim
import ./minc as minc

#_____________________________
proc compile (src :seq[DirFile]; obj :BuildTrg; force :bool) :void=
  let lang = obj.src.getLang()
  case lang
  of C       : c.compile(src, obj, force)
  of Cpp     : cpp.compile(src, obj, force)
  of Nim     : nim.compile(src, obj, force)
  of MinC    : minc.compile(src, obj, force)
  of Unknown : cerr "Tried to compile and Unknown language."

#_____________________________
proc build (obj :var BuildTrg; run :bool= false; force :bool= false) :void=
  if not obj.cc.exists: cerr &"Trying to compile {obj.trg} with {$obj.cc}, but the compiler binary couldn't be found."
  if not quiet: info.report(obj)  # Report build information to console when not quiet
  if force and dirExists(cfg.cacheDir.string):
    os.removeDir cfg.cacheDir.string  # Force building all files by removing the cacheDir
  dirs.setup( cfg.cacheDir )          # Setup the cache folder for confy.
  dirs.adjustRemotes( obj )           # Search for files in the remote folders, when they are missing in current.
  obj.root.setup()                    # Setup the root folder of the project.
  compile(obj.src, obj, force)
  log &"Finished building {obj.trg}."
  if run and obj.kind == Program:
    let bin = string obj.root/obj.sub/obj.trg.toBin(obj.syst.os)
    log &"Running {bin} ..."
    sh bin

#_____________________________
const ReservedKeywords = ["all", "examples", "tests", "tasks"]
#_____________________________
proc build *(obj :var BuildTrg; keywords :seq[string]= @["all"]; run :bool= false; force :bool= false) :void=
  if cfg.verbose: cfg.quiet = off  # Disable quiet when verbose is active.
  if obj.trg.string in ReservedKeywords: cerr &"Found a target that uses a reserved keyword as its .trg= field:\n  {obj.trg}\nThe list of reserved keywords is:\n  {ReservedKeywords}"
  block checkKeywords:
    # Search for "all" and empty cases
    if state.keywordList.len == 0 and "all" in keywords:
      break checkKeywords # Build all targets marked with `all` when user didn't request keywords
    elif "all" in state.keywordList and "examples" notin keywords and "tests" notin keywords:
      break checkKeywords # Search for `all` keyword (always build when all is requested)
    # Search for object.target as a keyword in the user-requested list
    if obj.trg.string in state.keywordList: break checkKeywords
    # Search inside the list of object-specific keywords
    for key in keywords:
      if key in state.keywordList: break checkKeywords
      # Search for the `examples` or `tests` cases
      case key
      of "examples":
        if "examples" notin state.keywordList: continue
        for file in obj.src: # Object is considered an example if one of its files is contained in cfg.examplesDir
          if cfg.examplesDir.string in file.path.string: break checkKeywords
      of "tests": # Object is considered a test if one of its files is contained in cfg.testsDir
        if "tests" notin state.keywordList: continue
        for file in obj.src:
          if cfg.testsDir.string in file.path.string: break checkKeywords
      else:discard
    # Key was not requested, and not a preset key. Return without doing anything
    return
  # Key was found. Continue building
  obj.build(run,force)
#_____________________________
proc build *(obj :BuildTrg; keywords :seq[string]= @["all"]; run :bool= false; force :bool= false) :void=
  var tmp :BuildTrg= obj
  tmp.build(keywords, run, force)
