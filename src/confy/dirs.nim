#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os except `/`
import std/strformat
# @deps confy
import ./types
import ./cfg
import ./tool/strings
import ./tool/paths
import ./tool/logger
import ./tool/helper

#_____________________________
# DirFile Tools
#___________________
proc new *(_:typedesc[DirFile]; dir :Dir|string; file :Fil|string) :DirFile=  DirFile(dir: Dir(dir), file:Fil(file))
  ## Creates a DirFile object with the given input data. Alias to DirFile( ... ) for ergonomics.
#___________________
proc isObj (trg :Fil) :bool=  trg.splitFile.ext in [ext.unix.obj, ext.win.obj, ext.mac.obj]  # Duplicate of builder/base/isObj, to avoid cyclic dependency
#___________________
proc toDirFile *(file :Fil; dir :Dir= cfg.srcDir) :DirFile=
  ## Converts a file path to its internal confy representation, as a separate dir and file.
  ## A file is always represented internally as a relative path, plus its dir, so that remotes and output dir can be swapped without issues.
  if file.isObj: return DirFile(file: file, dir: Dir("")) # Do not adjust object files at all, since they don't need to be compiled.
  if dir.string notin file.string: cerr &"The file {file} has been sent with an incorrect structure. It should be relative to {dir}, but isn't."
  result.dir  = dir
  result.file = file.string.replace(if not dir.string.endsWith(os.DirSep): dir.string & os.DirSep else: dir.string, "").Fil
proc toDirFile *(files :seq[Fil]; dir :Dir= cfg.srcDir) :seq[DirFile]=
  ## Converts a list of files to the internal confy representation, as separate dir/files.
  ## All files must be coming from the same srcDir
  for file in files: result.add file.toDirFile(dir)
proc path *(file :DirFile) :Fil=  file.dir/file.file
  ## Converts a DirFile to its complete path representation.
proc join *(files :seq[DirFile]; sep :string= " ") :string=
  ## Converts a list of DirFiles into a single string containing all their paths merged together
  for file in files: result.add file.path.string & sep
proc findNoExt *(file :DirFile; lang :Lang) :DirFile=
  ## Find a file that has no extension, and return it readjusted when possible.
  ## Returns the same file when the process fails.
  let filepath = file.dir/file.file
  let langExt  = lang.defaultExt
  for found in file.dir.string.walkDir:
    if filepath.string in found.path:
      let res = found.path.splitFile()
      if langExt != res.ext: continue  # A file matched, but its extension is incorrect
      return DirFile(dir: Path(res.dir), file: Path(res.name & res.ext))
  # Failed the search. Return the same file
  result = file


#_____________________________
# Glob Path Creation
#___________________
proc glob *(dir :Dir; ext :string= ".c"; rec :bool= false) :seq[DirFile]=
  ## Globs every file in the given folder that has the given ext.
  ## `ext` the extension to search for. Default: `.c`
  ## `rec` recursive search in all folders and subfolders when true. Default: `false`
  if rec:
    for file in dir.string.walkDirRec:
      if file.endsWith(ext): result.add DirFile.new(dir, file.replace(dir.string, "") )
  else:
    for file in dir.string.walkDir:
      if file.path.endsWith(ext): result.add DirFile.new(dir, file.path.replace(dir.string, "") )


