#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/strformat
import std/json
# @deps External
import pkg/jsony
# @deps confy
import ../../types
import ../../cfg
import ../../tool/dl
import ../../tool/helper
# @deps zigcc
import ./types


const master = "master"
const index  = "https://ziglang.org/download/index.json"
#_____________________________
proc download (trg :string= cfg.zigJson.string) :void=  dl.file(index, trg)
  ## Downloads the latest zig json from the website.
proc yesterday (trg :string= cfg.zigJson.string) :bool=  Fil(trg).noModSince(hours = 24)
  ## Returns true if the json file hasn't been updated in the last 24h.

#_____________________________
proc parse (trg :string= cfg.zigJson.string; downl :bool= false) :ZigIndex=
  ## Parses the downloaded zig download index json, and returns a ZigVersion object.
  ## Downloads the file if it does not already exist, or if `downl` is omitted..
  if downl or not trg.fileExists or trg.yesterday(): trg.download()
  for name,val in trg.readFile.fromJson().pairs:
    result.add ZigVersion(name: name, data: val.toJson.fromJson(ZigData))

#_____________________________
proc zigCPU (cpu :string= hostCPU) :string=
  ## Returns the zig version of the given CPU string. Defaults to current host.
  case cpu
  of "amd64": result = "x86_64"
  else:       result = cpu
proc zigOS  (os :string= hostOS) :string=
  ## Returns the zig version of the given OS string. Defaults to current host.
  case os
  of "macosx": result = "macos"
  else:        result = os

#_____________________________
proc file (data :ZigData) :ZigFile=
  ## Returns the file information to download the correct version for the current hostOS+hostCPU.
  let syst = &"{zigCPU()}-{zigOS()}"
  for name,val in data.fieldPairs:
    when val is ZigFile:
      if syst == name: return val

#_____________________________
proc latestData (trg :ZigIndex) :ZigData=
  ## Returns the data for the latest non-master version available.
  for ver in trg:
    if ver.name == master: continue
    result = ver.data
    if result.version == "":
      result.version = ver.name  # Add entry name as version. Entries don't have subversion
    return                       # exit on first hit
proc latest (trg :ZigIndex) :string=
  ## Returns the name of the latest non-master version available in the given parsed index.
  result = trg.latestData.version
proc latest *(trg :string= cfg.zigJson.string) :string=  trg.parse.latest()
  ## Returns the name of the latest non-master version available, using the json file.

#_____________________________
proc url (info :ZigFile) :string=  info.tarball
  ## Returns the url to download the given ZigFile.
proc url (data :ZigData) :string=  data.file.url
  ## Returns the url to download the correct version for the current hostOS+hostCPU.
#_____________________________
proc url (vers :string; json :ZigIndex) :string=
  ## Returns a string with the `trg` version url from the given parsed `json` index.
  for ver in json:
    if ver.name == vers: return ver.data.url
proc url *(vers :string; json :string= cfg.zigJson.string) :string=  vers.url( json.parse() )
  ## Returns a string with the `trg` version url.


when isMainModule:
  echo master.url()
  echo latest().url()

