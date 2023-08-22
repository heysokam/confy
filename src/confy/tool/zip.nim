#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
import std/strutils
# External dependencies
import pkg/zippy/ziparchives
# confy dependencies
import ../cfg


# TODO: liblzma wrapper
#     : https://github.com/tukaani-project/xz
let tarxz = if cfg.verbose: "tar -xvf" else: "tar -xf"

proc xunzip (file, trgDir :string; force :bool= false) :void=
  when not defined(unix):
    {.warning: &"Extracting .tar.xz files with {tarxz} is only tested on unix. Download and extract the zig compiler manually."}
    return
  let subDir = file.lastPathPart.splitFile.name.splitFile.name  # Basename of the file, without extensions
  let xDir   = trgDir.parentDir()  # Extract dir. The tar command will create a subdir in here.
  let resDir = xDir/subDir         # Resulting dir of the tar command.
  let cmd    = &"{tarxz} {file} -C {xDir}"
  discard execShellCmd cmd
  resDir.copyDirWithPermissions(trgDir)
  resDir.removeDir

proc unzip *(file, trgDir :string) :void=
  if file.endsWith(".tar.xz"): file.xunzip(trgDir)
  else:                        file.extractAll(trgDir)

