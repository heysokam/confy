#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
# @deps confy
import ../../cfg
import ../../tool/dl
import ../../tool/zip
# @deps zigcc
import ./json
import ./zcfg

#_____________________________
proc exists (force=false) :bool=
  ## @descr Returns true if the zig compiler file exists.
  if cfg.zigcc.systemBin:
    let found = findExe( zcfg.getRealBin() ) != ""
    if not found: raise newException(OSError, "Please install the Zig compiler before continuing, or configure the option `cfg.zigcc.systemBin = off` so that a local compiler is automatically downloaded for your project.")
    return found
  elif force : return false  # Skip searching when we are forcing a redownload
  else:                      # cfg.zigcc.systemBin:off -> Search for the binary
    return zcfg.getRealBin().fileExists or  # Search for the file first
           zcfg.getRealBin().findExe != ""  # Or run it if that failed (could be just `zig` without a path)

#_____________________________
proc download *(
    trg    : string = cfg.zigJson.string;
    dir    : string = cfg.zigDir.string;
    tmpDir : string = cfg.binDir.string;
    force  : bool   = false
  ) :void=
  ## @descr Downloads the correct zig binaries for the current hostCPU/hostOS.
  let link = trg.latest.url()
  let file = dir/link.lastPathPart
  if not dir.dirExists: dir.createDir
  if force or not file.fileExists:  dl.file(link, file)
  if not fileExists( dir/zcfg.name ):  file.unzip(dir)

#_____________________________
proc initOrExists *(force=false) :bool=
  ## @descr Initializes the zig compiler binary, or returns true if its already initialized.
  if bin.exists(force=force): return true  # Return true and skip downloading when it exists
  download(force=force)
  return bin.exists()

