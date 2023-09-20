#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/strformat
import std/sets
# confy dependencies
import ../types
import ../cfg
import ../tool/logger
import ../tool/db
import ../tool/helper
import ../dirs
import ../info
import ../task/state
# Builder module dependencies
from   ./C   as cc import nil
from   ./zig as z  import nil
from   ./nim as n  import nil
import ./helper as bhelp

#_____________________________
proc compile (src :seq[DirFile]; obj :BuildTrg; force :bool) :void=
  for it in src:
    if it.file.splitFile.ext == ".nim": # Compile files and exit early for nim
      n.compile(src, obj, force)
      return
  case obj.cc
  of GCC   : cc.compile(src, obj)
  of Clang : cc.compile(src, obj)
  of Zig   : z.compile(src, obj)


#_____________________________
proc build (obj :var BuildTrg; run :bool= false; force :bool= false) :void=
  if not obj.cc.exists: cerr &"Trying to compile {obj.trg} with {$obj.cc}, but the compiler binary couldn't be found."
  if not quiet: info.report(obj)      # Report build information to console when not quiet
  cfg.cacheDir.setup()                # Setup the cache folder for confy.
  obj.adjustRemotes()                 # Search for files in the remote folders, when they are missing in current.
  obj.root.setup()                    # Setup the root folder of the project.
  cfg.db.init()                       # Initialize the database
  var modif :seq[DirFile]
  if obj.lang == Nim: modif = obj.src                 # Skip the database for Nim files
  else:               modif = cfg.db.update(obj.src)  # Find all the files that have been modified
  if force: compile(obj.src, obj, force)              # Force building all files
  else:
    if modif.len == 0:  log &"{obj.trg} is already up to date."; return
    compile(modif, obj, force)        # Compile only the modified files.
  if run and obj.kind == Program:
    log &"Finished building {obj.trg}. Running..."
    sh obj.root/obj.sub/obj.trg

#_____________________________
const ReservedKeywords = ["all", "examples", "tests", "tasks"]
#_____________________________
proc build *(obj :var BuildTrg; keywords :seq[string]= @["all"]; run :bool= false; force :bool= false) :void=
  if cfg.verbose: cfg.quiet = off  # Disable quiet when verbose is active.
  if obj.trg in ReservedKeywords: cerr &"Found a target that uses a reserved keyword as its .trg= field:\n  {obj.trg}\nThe list of reserved keywords is:\n  {ReservedKeywords}"
  block checkKeywords:
    # Search for "all" and empty cases
    if state.keywordList.len == 0 and "all" in keywords:
      break checkKeywords # Build all targets marked with `all` when user didn't request keywords
    elif "all" in state.keywordList and "examples" notin keywords and "tests" notin keywords:
      break checkKeywords # Search for `all` keyword (always build when all is requested)
    # Search for object.target as a keyword in the user-requested list
    if obj.trg in state.keywordList: break checkKeywords
    # Search inside the list of object-specific keywords
    for key in keywords:
      if key in state.keywordList: break checkKeywords
      # Search for the `examples` or `tests` cases
      case key
      of "examples":
        if "examples" notin state.keywordList: continue
        for file in obj.src: # Object is considered an example if one of its files is contained in cfg.examplesDir
          if cfg.examplesDir in file.path: break checkKeywords
      of "tests": # Object is considered a test if one of its files is contained in cfg.testsDir
        if "tests" notin state.keywordList: continue
        for file in obj.src:
          if cfg.testsDir in file.path: break checkKeywords
      else:discard
    # Key was not requested, and not a preset key. Return without doing anything
    return
  # Key was found. Continue building
  obj.build(run,force)

