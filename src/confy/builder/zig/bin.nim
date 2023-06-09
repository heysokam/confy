#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
# confy dependencies
import ../../cfg
import ../../tool/dl
import ../../tool/zip
# zig dependencies
import ./json
import ./zcfg

#_____________________________
proc exists () :bool=
  ## Returns true if the zig compiler file exists.
  let dir  = zigDir
  let zbin = dir/zcfg.name
  result = fileExists( zbin )

#_____________________________
proc download *(trg :string= cfg.zigJson.string; dir :string= cfg.zigDir; tmpDir :string= cfg.binDir; force :bool= false) :void=
  ## Downloads the correct zig binaries for the current hostCPU/hostOS.
  let link = trg.latest.url()
  let file = dir/link.lastPathPart
  if not dir.dirExists: dir.createDir
  if force or not file.fileExists:  dl.file(link, file)
  if not fileExists( dir/zcfg.name ):  file.unzip(dir)

#_____________________________
proc initOrExists *() :bool=
  ## Initializes the zig compiler binary, or returns true if its already initialized.
  download()
  result = exists()

