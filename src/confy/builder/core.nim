#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
import std/strutils
import std/sequtils
# confy dependencies
import ../types
import ../cfg
import ../tool/logger
import ../tool/db
import ../tool/helper
import ../dirs
import ../info
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
  of GCC:        cc.compile(src, obj)
  of Clang:      cc.compile(src, obj)
  of Zig:        z.compile(src, obj)


#_____________________________
proc build *(obj :var BuildTrg; run :bool= false; force :bool= false) :void=
  if verbose: cfg.quiet = off       # Disable quiet when verbose is active.
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
    sh obj.root/obj.trg

