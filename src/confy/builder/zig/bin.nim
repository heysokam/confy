#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/os
import std/strformat
# confy dependencies
import ../../cfg
import ../../tool/dl
import ../../tool/zip
# zig dependencies
import ./json
import ./zcfg

#_____________________________
proc exists (force=false) :bool=
  ## Returns true if the zig compiler file exists.
  if cfg.zigSystemBin and zcfg.realBin.lastPathPart == zcfg.name: return true  # Using system bin
  if force: return false                           # Skip searching when we are forcing a redownload
  result =                                         # Search for the binary
    zcfg.realBin.fileExists or                     # Search for the file first
    execShellCmd( &"{zcfg.realBin} version" ).bool # Or run it if that failed (could be just `zig` without a path)

#_____________________________
proc download *(trg :string= cfg.zigJson.string; dir :string= cfg.zigDir; tmpDir :string= cfg.binDir; force :bool= false) :void=
  ## Downloads the correct zig binaries for the current hostCPU/hostOS.
  let link = trg.latest.url()
  let file = dir/link.lastPathPart
  if not dir.dirExists: dir.createDir
  if force or not file.fileExists:  dl.file(link, file)
  if not fileExists( dir/zcfg.name ):  file.unzip(dir)

#_____________________________
proc initOrExists *(force=false) :bool=
  ## Initializes the zig compiler binary, or returns true if its already initialized.
  if bin.exists(force=force): return true  # Return true and skip downloading when it exists
  download(force=force)
  return bin.exists()

