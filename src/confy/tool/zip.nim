#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/strformat
# @deps External
import pkg/zippy/ziparchives
# @deps confy
import ../cfg
# @deps confy.helper
import ./strings


# TODO: liblzma wrapper
#     : https://github.com/tukaani-project/xz
let tarxz = if cfg.verbose: "tar -xvf" else: "tar -xf"

proc xunzip (file, trgDir :string; subDir :string= ""; force :bool= false) :void=
  ## @descr
  ##  UnZips the given tar compatible file into trgDir, calling `tar -xf` as an execShellCmd.
  ##  Extracts into current, and then moves the generated folder into trgDir
  let xDir   = trgDir.parentDir()  # Extract dir. The tar command will create a subdir in here.
  let resDir = xDir/subDir         # Resulting dir of the tar command.
  let cmd    = &"{tarxz} {file} -C {xDir}"
  discard execShellCmd cmd
  resDir.copyDirWithPermissions(trgDir)
  resDir.removeDir

proc zunzip (file, trgDir :string; subdir :string= ""; force :bool= false) :void=
  ## @descr
  ##  UnZips the given zippy compatible file into trgDir.
  ##  Stores contents in a temp folder and then copies them back into trgDir, and removes the temp folder.
  try: file.extractAll(trgDir)
  except ZippyError: # Destination exists, so we make a temp folder and manually move the files
    let tmpDir = trgDir/"temp"
    if tmpDir.dirExists: tmpDir.removeDir
    file.extractAll(tmpDir)
    var xDir :string
    if dirExists tmpDir/subDir: xDir = tmpDir/subDir
    else:  # silly case for zippy not understanding extraction, so .... search for it :facepalm:
      for dir in tmpDir.walkDir:
        if dir.path.dirExists() and subDir in dir.path:
          xDir = dir.path
    echo xDir
    xDir.copyDir(trgDir)
    tmpDir.removeDir

proc unzip *(file, trgDir :string) :void=
  ## @descr
  ##  UnZips the given file into trgDir, based on its extension.
  ##  Will use tar -xf for tar.xz and zippy for any other filetype
  let subDir = file.lastPathPart.splitFile.name.splitFile.name  # Basename of the file, without extensions
  if file.endsWith(".tar.xz"): file.xunzip(trgDir, subDir)
  else: file.zunzip(trgDir, subDir)

