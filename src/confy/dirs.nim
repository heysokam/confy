#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os except `/`
# @deps ndk
import nstd/strings
import nstd/paths
# @deps confy
import ./types
import ./cfg
import ./tool/logger
import ./tool/helper
import ./tool/git


#_____________________________
# Dir Helpers
#___________________
proc chgDir *(path :DirFile; to :Dir; sub :Dir= Dir("")) :DirFile=  DirFile(dir:to, file:path.file.string.replace(sub.string, "").Fil)
  ## @descr Returns a new DirFile with its path be coming from dir `to` instead.
proc remap *(files :seq[DirFile]; to :Dir) :seq[DirFile]=
  ## @descr Returns a new DirFile list, with their paths coming from dir `to` instead.
  for path in files: result.add DirFile(dir:to, file:path.file)


#_____________________________
# DirFile Tools
#___________________
proc new *(_:typedesc[DirFile]; dir :Dir|string; file :Fil|string) :DirFile=  DirFile(dir: Dir(dir), file:Fil(file))
  ## @descr Creates a DirFile object with the given input data. Alias to DirFile( ... ) for ergonomics.
#___________________
proc isObj (trg :Fil) :bool=  trg.splitFile.ext in [ext.unix.obj, ext.win.obj, ext.mac.obj]  # Duplicate of builder/base/isObj, to avoid cyclic dependency
#___________________
proc toDirFile *(file :Fil; dir :Dir= cfg.srcDir) :DirFile=
  ## @descr
  ##  Converts a file path to its internal confy representation, as a separate dir and file.
  ##  A file is always represented internally as a relative path, plus its dir, so that remotes and output dir can be swapped without issues.
  if file.isObj: return DirFile(file: file, dir: Dir("")) # Do not adjust object files at all, since they don't need to be compiled.
  if dir.string notin file.string: cerr &"The file {file} has been sent with an incorrect structure. It should be relative to {dir}, but isn't."
  result.dir  = dir
  result.file = file.replace(if not dir.endsWith(os.DirSep): dir.string & os.DirSep else: dir.string, "").Fil
#___________________
proc toDirFile *(files :seq[Fil]; dir :Dir= cfg.srcDir) :seq[DirFile]=
  ## @descr
  ##  Converts a list of files to the internal confy representation, as separate dir/files.
  ##  All files must be coming from the same srcDir
  for file in files: result.add file.toDirFile(dir)
#___________________
proc path *(file :DirFile) :Fil=  file.dir/file.file
  ## @descr Converts a DirFile to its complete path representation.
#___________________
proc join *(files :seq[DirFile]; sep :string= " ") :string=
  ## @descr Converts a list of DirFiles into a single string containing all their paths merged together
  for file in files: result.add file.path.string & sep
#___________________
proc findNoExt *(file :DirFile; lang :Lang) :DirFile=
  ## @descr
  ##  Find a file that has no extension, and return it readjusted when possible.
  ##  Returns the same file when the process fails.
  let filepath = file.dir/file.file
  let langExt  = lang.defaultExt
  for found in file.dir.string.walkDir:
    if filepath.string in found.path:
      let res = found.path.splitFile()
      if langExt != res.ext: continue  # A file matched, but its extension is incorrect
      return DirFile(dir: Path(res.dir), file: Path(res.name & res.ext))
  # Failed the search. Return the same file
  result = file
#___________________
proc getFileList *(src :seq[DirFile]; dir :Path= cfg.srcDir; rel :bool= false) :seq[Path]=
  ## @descr Returns {@arg src} as a list of paths relative to {@arg dir}
  for file in src:
    if rel : result.add file.path.relativePath(dir)
    else   : result.add file.path

#_____________________________
# Dir Setup
#___________________
proc setup *(trg :Dir) :void=
  if not quiet: log0 &"Setting up folder {trg}"
  let curr = if not trg.isAbsolute: cfg.binDir/trg else: trg
  block setupDir:
    if curr.string.dirExists and "bin" notin curr.string:
      if not quiet: log1 &"Folder {curr.absolutePath} already exists. Ignoring its setup."
      break setupDir
    createDir curr.string
  if cfg.binDir.string in curr.string:  (curr/".gitignore").string.writeFile(git.ignore)
  # elif cfg.libDir in curr:  (curr/".gitignore").writeFile(git.ignoreAll)

#_____________________________
# Glob Path Creation
#___________________
func shouldSkip (filters :openArray[Path]; file :Path) :bool=
  for filter in filters:
    if filter in file: return true
#___________________
proc glob *(
    dir     : Dir;
    ext     : string          = ".c";
    rec     : bool            = false;
    filters : openArray[Path] = @[];
  ) :seq[DirFile]=
  ## @descr
  ##  Globs every file in the given folder that has the given ext.
  ##  `ext`     Extension to search for. Default: `.c`
  ##  `rec`     Recursive search in all folders and subfolders when true. Default: `false`
  ##  `filters` List of paths that will be used to exclude/filter out files that contain any of them
  if rec:
    for file in dir.walkDirRec:
      if filters.shouldSkip(file): continue
      if file.string.endsWith(ext): result.add DirFile.new(dir, file.replace(dir.string, "") )
  else:
    for file in dir.walkDir:
      if filters.shouldSkip(file.path): continue
      if file.path.string.endsWith(ext): result.add DirFile.new(dir, file.path.replace(dir.string, "") )

#_____________________________
# Remotes Management
#___________________
proc fromRemote *(file :DirFile; dir :Dir; sub :Dir= Dir("")) :DirFile=
  ## @descr
  ##  Adjusts the input list of source files to be searched from `srcDir/*` first by default.
  ##  This is needed tor remap a remote glob into srcDir/subDir, so the files are searched inside the local srcDir first.
  if verbose: log1 &"Changing  {file.dir}  to  {dir}  for file:  {file.file}"
  result = file.chgDir(dir, sub)  # readability alias for chgDir
proc fromRemote *(list :seq[DirFile]; dir :Dir; sub :Dir= Dir("")) :seq[DirFile]=
  ## @descr
  ##  Adjusts the input list of source files to be searched from `srcDir/subDir` first by default.
  ##  This is needed to remap a remote glob into srcDir/, so the files are searched inside the local folder first.
  result = list.remap(dir/sub)  # readability alias for remap
#_____________________________
proc globRemote *(dir :Dir; ext :string= ".c"; rec :bool= false; sub :Dir= Dir("")) :seq[DirFile]=
  ## @descr
  ##  Globs every file that has the given `ext` in the input remote `dir`.
  ##  Returns the list of files, adjusted so they are searched from `cfg.srcDir` first.
  ##  `ext` the extension to search for. Default: `.c`
  ##  `rec` recursive search in all folders and subfolders when true. Default: `false`
  result = dir.glob(ext, rec).fromRemote(dir, sub)
#_____________________________
proc adjustRemotes *(obj :var BuildTrg) :void=
  ## @descr
  ##  Adjusts the list of source files in the object, based on its remotes.
  ##  Files will be:
  ##  - Searched for in `cfg.srcDir` first.
  ##  - Adjusted to come from the folders stored in the obj.remotes list when the local file is missing.
  if cfg.verbose: log &"Adjusting remotes for {obj.trg}."
  for file in obj.src.mitems:
    # Dont adjust object files. They don't need to be compiled
    if file.path.string.endsWith(".o"): continue
    # Dont adjust if the file exists
    if file.path.fileExists:
      if cfg.verbose: log1 &"Local file exists. Not adjusting :  {file.path}"
      continue
    # Adjust for a missing extension with Nim
    elif obj.lang == Lang.Nim and (not file.path.string.endsWith(".nim")):
      log1 &"Nim file was sent without extension. Searching for it at  {file.path}"
      file = file.findNoExt(Lang.Nim)
      continue
    # Search for the file in the remotes
    if obj.remotes.len < 1: cerr &"The source code file {file.path} couldn't be found."
    if cfg.verbose: echo " ... "; log1 &"File {file.file} doesn't exist in local. Searching for it in the remote folders list."
    for dir in obj.remotes:  # Search for the file in the remotes
      let adj = file.fromRemote(dir, obj.sub)
      if cfg.verbose: log1 &"File:  {file.path}\n{tab}Becomes:  {adj.path}"
      file = adj

