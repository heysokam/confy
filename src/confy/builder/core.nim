#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/strformat
# confy dependencies
import ../types
import ../logger
import ../dirs
import ../tools/db
import ../cfg as c
# Builder module dependencies
import ./gcc as cc

#_____________________________
proc build *(obj :var BuildTrg) :void=
  obj.root.setup()                  # Setup the root folder of the project.
  c.db.init()                       # Initialize the database
  var modif = c.db.update(obj.src)  # Find all the files that have been modified
  if modif.len == 0:  log &"{obj.trg} is already up to date."; return
  cc.compile(modif, obj.trg)        # Compile only the modified files.

