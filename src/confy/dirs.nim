#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os except `/`
import std/paths ; export paths
import std/dirs
import std/strutils
import std/sequtils
import std/strformat
# confy dependencies
import ./types
import ./tool/git
import ./tool/logger
import ./cfg

#_____________________________
# Dir Helpers
#___________________
proc chgDir *(file :Fil; dirFrom, dirTo :Dir) :Fil=  file.replace(dirFrom, dirTo)
  ## Changes the given `file` path from `dirFrom` to `dirTo`.
proc remap *(files :seq[Fil]; dirFrom, dirTo :Dir) :seq[Fil]=  files.mapIt( it.chgDir(dirFrom,dirTo) )
  ## Changes the path of all files in the given list from `dirFrom` to `dirTo`.

#_____________________________
# Dir Setup
#___________________
proc setup *(trg :Dir) :void=
  if not quiet: log0 &"Setting up folder {trg}"
  let curr = if not trg.isAbsolute: cfg.binDir/trg else: trg
  block:
    if curr.dirExists and "bin" notin curr:
      if not quiet: log1 &"Folder {curr.absolutePath} already exists. Ignoring its setup."
      break
    createDir curr
  if   cfg.binDir in curr:  (curr/".gitignore").writeFile(git.ignore)
  # elif cfg.libDir in curr:  (curr/".gitignore").writeFile(git.ignoreAll)

#_____________________________
# Glob Path Creation
#___________________
proc glob *(dir :Dir; ext :string= ".c"; rec :bool= false) :seq[Fil]=
  ## Globs every file in the given folder that has the given ext.
  ## `ext` the extension to search for. Default: `.c`
  ## `rec` recursive search in all folders and subfolders when true. Default: `false`
  if rec:
    for file in dir.string.walkDirRec:
      if file.endsWith(ext): result.add file.Fil
  else:
    for file in dir.string.walkDir:
      if file.path.endsWith(ext): result.add file.path.Fil

#_____________________________
# Remotes Management
#___________________
proc fromRemote *(file :Fil; dir :Dir; sub :Dir= Dir("")) :Fil=
  ## Adjusts the input list of source files to be searched from `srcDir/*` first by default.
  ## This is needed tor remap a remote glob into srcDir/subDir, so the files are searched inside the local srcDir first.
  if verbose: log1 &"Changing  {dir}  to  {sub}  for file:  {file.replace(sub&os.DirSep, \"\")}"
  result = file.chgDir(sub, dir)  # readability alias for chgDir
proc fromRemote *(list :seq[Fil]; dir :Dir; sub :Dir= Dir("")) :seq[Fil]=
  ## Adjusts the input list of source files to be searched from `srcDir/subDir` first by default.
  ## This is needed to remap a remote glob into srcDir/, so the files are searched inside the local folder first.
  result = list.remap(sub, dir)  # readability alias for remap
#_____________________________
proc globRemote *(dir :Dir; ext :string= ".c"; rec :bool= false; sub :Dir= Dir("")) :seq[Fil]=
  ## Globs every file that has the given `ext` in the input remote `dir`.
  ## Returns the list of files, adjusted so they are searched from `cfg.srcDir` first.
  ## `ext` the extension to search for. Default: `.c`
  ## `rec` recursive search in all folders and subfolders when true. Default: `false`
  result = dir.glob(ext, rec).fromRemote(dir, sub)
#_____________________________
proc adjustRemotes *(obj :var BuildTrg) :void=
  ## Adjusts the list of source files in the object, based on its remotes.
  ## Files will be:
  ## - Searched for in `cfg.srcDir` first.
  ## - Adjusted to come from the folders stored in the obj.remotes list when the local file is missing.
  if verbose: log &"Adjusting remotes for {obj.trg}."
  for file in obj.src.mitems:
    if file.fileExists:
      if verbose: log &"Local file exists. Not adjusting :  {file}"
      continue
    if obj.remotes.len < 1: cerr &"The source code file {file} couldn't be found."
    if verbose: echo " ... "; log1 &"File {file.lastPathPart} doesn't exist in local. Searching for it in the remote folders list."
    for dir in obj.remotes:  # Search for the file in the remotes
      let adj = file.fromRemote(dir, cfg.srcDir/obj.sub)
      if verbose: log1 &"File:  {file}\n{tab}Becomes:  {adj}"
      file = adj

