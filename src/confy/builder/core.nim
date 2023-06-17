#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
import std/strutils
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

#_____________________________
proc exists (c :Compiler) :bool=
  ## Returns true if the given compiler exists in the system.
  case c
  of Zig:   z.initOrExists()
  of GCC:   cc.exists(c)
  of Clang: cc.exists(c)
#_____________________________
proc compile (src :seq[Fil]; obj :BuildTrg) :void=
  case obj.cc
  of Zig:   z.compile(src, obj)
  of GCC:   cc.compile(src, obj)
  of Clang: cc.compile(src, obj)

#_____________________________
proc build *(obj :var BuildTrg; run :bool= false; force :bool= false) :void=
  if verbose: cfg.quiet = off       # Disable quiet when verbose is active.
  if not obj.cc.exists: cerr &"Trying to compile {obj.trg} with {$obj.cc}, but the compiler binary couldn't be found."
  if not quiet: info.report(obj)      # Report build information to console when not quiet
  obj.adjustRemotes()                 # Search for files in the remote folders, when they are missing in current.
  obj.root.setup()                    # Setup the root folder of the project.
  var modif :seq[Fil]
  if obj.cc == Zig: modif = obj.src   # Skip database management for Zig. It already has its own file cache manager.
  else:
    cfg.db.init()                     # Initialize the database
    modif = cfg.db.update(obj.src)    # Find all the files that have been modified
  if force: compile(obj.src, obj)     # Force building all files
  else:
    if modif.len == 0:  log &"{obj.trg} is already up to date."; return
    compile(modif, obj)             # Compile only the modified files.
  if run and obj.kind == Program:
    log &"Finished building {obj.trg}. Running..."
    sh obj.trg

