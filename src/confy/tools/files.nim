#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`, walkDirRec, walkDir, pcFile, fileExists, relativePath
from std/strutils import endsWith, contains, replace
# @deps confy
import ../types/base


#_______________________________________
# @section Remotes Management
#_____________________________
type Remotes * = object
  list  *:seq[PathLike]= @[] ## @descr
    ##  List of folders that the consumer of the remotes will use to search for the files
  autoAdjust  *:bool= true ## @descr
    ##  Signals the consumer of the Remotes object to auto-adjust the files based on the Remotes.list field
#___________________
func none *(_:typedesc[Remotes]) :Remotes= Remotes(list: @[], autoAdjust: false)
  ## @descr Returns an empty Remotes list that won't do anything
#___________________
func with *(_:typedesc[Remotes]; dir :PathLike) :Remotes= Remotes(list: @[dir], autoAdjust: true)
  ## @descr Returns a Remotes object that will autoadjust files to {@arg dir}
#___________________
func merge *(list :varargs[Remotes]) :Remotes=
  ## @descr
  ##  Returns a Remotes object that will be the combined result of all remotes in the {@arg list}
  ##  `result.autoAdjust` will only be true if at least one of the entries defines it as true
  result.autoAdjust = false
  for remote in list:
    result.list.add remote.list
    result.autoAdjust = result.autoAdjust or remote.autoAdjust
#___________________
func adjust *(
    R     : Remotes;
    files : varargs[PathLike];
    root  : PathLike;
  ) :seq[PathLike]=
  ## @descr Manually adjusts the given {@arg files} list based on the folders at {@arg R}.list
  let list = @files
  if R.list.len == 0: return
  for file in list:
    for dir in R.list:
      {.cast(noSideEffect).}:  # Calling relativePath should be safe here
        let file_rel = file.relativePath(root)
      # let file_dir   = file.replace(file_rel, "")
      let file_path  = dir/file_rel
      {.cast(noSideEffect).}:  # Calling fileExists should be safe here
        if file_path.fileExists():
          result.add file_path
          break  # go to next file


#_______________________________________
# @section Glob Path Creation
#_____________________________
func shouldSkip (
    filters : openArray[PathLike];
    file    : PathLike;
  ) :bool=
  for filter in filters:
    if filter in file: return true
#___________________
# @note: Remember `treeform/globby` : https://github.com/treeform/globby/blob/master/src/globby.nim
proc glob *(
    dir     : PathLike;
    ext     : string              = ".c";
    rec     : bool                = true;
    rel     : bool                = false;
    filters : openArray[PathLike] = @[];
  ) :seq[PathLike]=
  ## @descr
  ##  Globs every file in the given folder that has the given ext.
  ##  The resulting list of files will be relative to {@arg dir}
  ##  {@arg ext}     Extension to search for.
  ##  {@arg rec}     Recursive search in all folders and subfolders when true.
  ##  {@arg rel}     Files paths will be relative to {@arg dir} when true.
  ##  {@arg filters} List of paths that will be used to exclude/filter out files that contain any of them
  if rec:
    for file in dir.walkDirRec(relative=rel, skipSpecial=true):
      if filters.shouldSkip(file): continue
      if file.endsWith(ext): result.add file
  else:
    for file in dir.walkDir(relative=rel, skipSpecial=true):
      if file.kind != pcFile: continue
      if filters.shouldSkip(file.path): continue
      if file.path.endsWith(ext): result.add file.path

