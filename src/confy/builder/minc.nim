#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
# @deps confy
import ../types
import ../tool/logger
# @deps confy.builder
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/bin as z


#_____________________________________________________
# MinC: General Config
#_____________________________
template getRealBin *() :string=
  if cfg.minc.systemBin: cfg.minc.cc else: string cfg.mincDir/"bin"/cfg.minc.cc

#_____________________________________________________
# MinC Compiler : Builder
#_____________________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool= false) :void=
  cerr "Tried to compile MinC, but its not implemented."
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

