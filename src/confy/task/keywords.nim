#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/sets
# confy dependencies
import ../tool/opts

#_______________________________________
proc getList *() :OrderedSet[string]=
  let cli = opts.getCLI()
  for arg in cli.args:
    if not os.fileExists(arg): result.incl arg

