#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/os import `/`
# @deps ndk
import nstd/strings
import nstd/paths
# @deps confy
import ./types as confy
import ./cfg
import ./tool/logger
import ./tool/helper
import ./tool/git


#_____________________________
# @section Dir Setup
#___________________
proc setup *(trg :Dir) :void=
  if not quiet: log0 &"Setting up folder {trg}"
  let curr = if not trg.isAbsolute: cfg.binDir/trg else: trg
  block setupDir:
    if curr.exists and "bin" notin curr.path:
      if not quiet: log1 &"Folder {curr.absolute} already exists. Ignoring its setup."
      break setupDir
    curr.create
  if cfg.binDir.path in curr.path:  (curr.path/".gitignore").writeFile(git.ignore)
  # elif cfg.libDir in curr:  (curr/".gitignore").writeFile(git.ignoreAll)
#___________________
proc findNoExt *(file :Fil; lang :Lang) :Fil=
  ## @descr
  ##  Find a file that has no extension, and return it readjusted when possible.
  ##  Returns the same file when the process fails.
  let langExt  = lang.defaultExt
  for found in file.walkDir:
    if file.path in found.path:
      if langExt != found.ext: continue  # A file matched, but its extension is incorrect
      return found
  # Failed the search. Return the same file
  result = file


#_______________________________________
# @section Extra Path Tools
#_____________________________
proc isObj (trg :Fil) :bool=
  if trg.isDir: return false
  result = trg.ext in [confy.ext.unix.obj, confy.ext.win.obj, confy.ext.mac.obj]  # Duplicate of builder/base/isObj, to avoid cyclic dependency
#___________________
proc toPath *(
    file : Fil;
    dir  : Dir = cfg.srcDir;
  ) :Fil=
  ## @descr
  ##  Converts a file path to its internal confy representation, as a separate dir and file.
  ##  A file is always represented internally as a relative path, plus its dir, so that remotes and output dir can be swapped without issues.
  if file.isObj: return file # Do not adjust object files at all, since they don't need to be compiled.
  if dir.path notin file.path: cerr &"The file {file} has been sent with an incorrect structure. It should be relative to {dir}, but isn't."
  result = paths.newFile(dir.dir, file.basename, file.sub)
#___________________
proc toPaths *(
    files : PathList;
    dir   : Dir = cfg.srcDir;
  ) :PathList=
  ## @descr
  ##  Converts a list of files to the internal confy representation, as separate dir/files.
  ##  All files must be coming from the same srcDir
  for file in files: result.add file.toPath(dir)


#_______________________________________
# @section Remotes Management
#_____________________________
proc fromRemote *(
    file : Fil;
    dir  : Dir;
    sub  : Dir= newEmpty Dir;
  ) :Fil=
  ## @descr
  ##  Adjusts the input list of source files to be searched from `srcDir/*` first by default.
  ##  This is needed tor remap a remote glob into srcDir/subDir, so the files are searched inside the local srcDir first.
  ## @note Readability alias for chgDir
  if verbose: log1 &"Changing  {file.dir}  to  {dir/sub}  for file:  {file}"
  if sub == UndefinedPath : result = file.chgDir(dir)
  else                    : result = file.chgDir(dir, sub.path)
#___________________
proc adjustRemotes *(obj :var BuildTrg) :void=
  ## @descr
  ##  Adjusts the list of source files in the object, based on its remotes.
  ##  Files will be:
  ##  - Searched for in `cfg.srcDir` first.
  ##  - Adjusted to come from the folders stored in the obj.remotes list when the local file is missing.
  if cfg.verbose: log &"Adjusting remotes for {obj.trg}."
  for file in obj.src.mitems:
    # Dont adjust object files. They don't need to be compiled
    if file.ext == ".o": continue
    # Dont adjust if the file exists
    if file.exists:
      if cfg.verbose: log1 &"Local file exists. Not adjusting :  {file.path}"
      continue
    # Adjust for a missing extension with Nim
    elif obj.lang == Lang.Nim and (not file.path.string.endsWith(".nim")):
      log1 &"Nim file was sent without extension. Searching for it at  {file.path}"
      file = file.findNoExt(Lang.Nim)
      continue
    # Search for the file in the remotes
    if obj.remotes.len < 1: cerr &"The source code file {file.path} couldn't be found."
    if cfg.verbose: echo " ... "; log1 &"File {file} doesn't exist in local. Searching for it in the remote folders list."
    for dir in obj.remotes:  # Search for the file in the remotes
      let adj = file.fromRemote(dir, obj.sub)
      if cfg.verbose: log1 &"File:  {file}\n{tab}Becomes:  {adj}"
      file = adj

