#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps ndk
import nstd/strings
import nstd/paths
# @deps confy
import ../cfg
import ../types
import ../dirs
import ../tool/logger
import ../tool/helper
import ../task/deps
# @deps confy.builder
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/zcfg


#_____________________________________________________
# @section MinC: General Config
#_____________________________
const KnownExts = [".cm",".nim"]
template getRealBin *() :string=
  if cfg.minc.systemBin: cfg.minc.cc else: string cfg.mincDir/"bin"/cfg.minc.cc


#_____________________________________________________
# @section MinC: Builder
#_____________________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool= false) :void=
  var srcFile :string
  var cfiles  :string
  for file in src:
    case file.file.splitFile.ext
    of KnownExts : srcFile = file.path.string  # TODO:maybe? Multi-file support ?
    of ".c"      : cfiles.add &"--cFile:{file.path.string} "
    else         : continue
  let typFlag = case obj.kind
    of SharedLibrary : "--passL=\"-shared\""
    of StaticLibrary : "--passL=\"\""
    else             : ""
  let trgFile = case obj.kind
    of Program       : obj.trg.toBin(obj.syst.os)
    of SharedLibrary : obj.trg.toLib(obj.syst.os)
    of StaticLibrary : obj.trg # TODO
    else             : obj.trg
  let verb = if cfg.verbose: "--verbose" else: ""
  # Find the cross-compilation target
  let cross = if obj.syst != getHost(): &"--os:{obj.syst.toZig.os} --cpu:{obj.syst.toZig.cpu}" else: ""
  let cmd   = &"{minc.getRealBin()} c {verb} --zigBin:{zcfg.getRealBin()} --cacheDir:{cfg.cacheDir} --binDir:{obj.root/obj.sub} {cross} {obj.deps.to(Nim)} {typFlag} {obj.args} {cfiles} {srcFile} {trgFile}"
  dbg "Running command:\n  ",cmd
  sh cmd


  ##[ # TODO
  let typFlag = case obj.kind
    of SharedLibrary : "--app:lib"
    of StaticLibrary : "--app:staticlib"
    else             : ""
  ]##

