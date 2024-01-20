#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/strformat import `&`
# @deps confy
import ../cfg
import ../types
import ../dirs
import ../tool/logger
import ../tool/paths
import ../tool/helper
import ../task/deps
# @deps confy.builder
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/bin as z
import ./zigcc/zcfg


#_____________________________________________________
# MinC: General Config
#_____________________________
const KnownExts = ["cm","nim"]
template getRealBin *() :string=
  if cfg.minc.systemBin: cfg.minc.cc else: string cfg.mincDir/"bin"/cfg.minc.cc

#_____________________________________________________
# MinC Compiler : Builder
#_____________________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool= false) :void=
  var srcFile :string
  var cfiles  :string
  for file in src:
    case file.file.splitFile.ext
    of ".cm" : srcFile = file.path.string
    of ".c"  : cfiles.add &"--cFile:{file.path.string} "
    else     : continue
  let cmd = &"{minc.getRealBin()} c --zigBin:{zcfg.getRealBin()} --cacheDir:{cfg.cacheDir} --outDir:{obj.root/obj.sub} {obj.deps.to(Nim)} {obj.args} {cfiles} {srcFile} {obj.trg.toBin(obj.syst.os)}"
  dbg "Running command:\n  ",cmd
  sh cmd
  #TODO os,cpu

  # if obj.kind == Object: cerr "Compiling Nim into Object files is not supported. Run nim manually with `--noLinking:on|off`"
  # buildNimZ(force=force) # Build the NimZ aliases when they do not exist
  # var zigTarget :string
  # if obj.syst != getHost():
  #   let zigSyst = obj.syst.toZig
  #   let nimSyst = obj.syst.toNim
  #   zigTarget.add &"--os:{nimSyst.os} --cpu:{nimSyst.cpu} "
  #   zigTarget.add &"--passC:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
  #   zigTarget.add &"--passL:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
  # let typFlag = case obj.kind
  #   of SharedLibrary : "--app:lib"
  #   of StaticLibrary : "--app:staticlib"
  #   else             : ""
  # let verb = if cfg.verbose: "--verbosity:3" elif cfg.quiet: "--hints:off" else:""
  # var cc = &"{nim.getRealBin()} {cfg.nim.backend} {verb} {typFlag}"
  # if force: cc &= " -f"
  # case  obj.cc  # Add extra parameters for the compilers when required
  # of    Zig:    cc = fmt(ZigTemplate)
  # of    GCC:    cc &= " --cc:gcc"
  # of    Clang:  cc &= " --cc:clang"
  # if cfg.nim.unsafe.functionPointers: cc.add " --passC:-Wno-incompatible-function-pointer-types"
  # let paths = obj.deps.to(Nim)
  # let cmd = &"{cc} --out:{obj.trg.toBin(obj.syst.os)} --outdir:\"{obj.root/obj.sub}\" {paths} {obj.args} {obj.src.join()}"
  # if cfg.verbose     : echo cmd
  # elif not cfg.quiet : echo &"{cfg.Cstr} {obj.trg}"
  # sh cmd

