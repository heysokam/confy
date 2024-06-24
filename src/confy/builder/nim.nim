#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/os import `/`
# @deps ndk
import nstd/strings
import nstd/paths
import get/nim/nimz
# @deps confy
import ../types
import ../cfg
import ../dirs
import ../tool/logger
import ../tool/helper as t
import ../task/deps
# @deps confy.builder
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/zcfg
import ./zigcc/bin as z


#_______________________________________
# Nim: General Config
#_____________________________
template getRealBin *() :string=
  if cfg.nim.systemBin: cfg.nim.cc else: path cfg.nimDir/"bin"/cfg.nim.cc
proc getRealNimble *() :string=
  let cc  = &" --nim:{nim.getRealBin()}"
  let bin = "nimble"
  if cfg.nim.systemBin: bin else: path(cfg.nimDir/"bin"/bin) & cc


#_______________________________________
# NimZ Compiler : Alias Manager
#_____________________________
proc buildNimZ (
    force   : bool = false;
  ) :tuple[cc:string, cpp:string] {.discardable.}=
  ## @descr Writes and builds the source code of both NimZ aliases when they do not exist.
  let res = nimz.build(
    trgDir  = cfg.zigDir,
    nim     = nim.getRealBin(),
    zigBin  = os.lastPathPart(zcfg.getRealBin()),
    force   = force,
    verbose = cfg.verbose,
    ) # << nim.buildNimZ( ... )
  result = (res.cc.path, res.cpp.path)


#_______________________________________
# NimZ Compiler : Builder
#_____________________________
proc compile *(
    src   : PathList;
    obj   : BuildTrg;
    force : bool = false
  ) :void=
  if obj.kind == Object: cerr "Compiling Nim into Object files is not supported. Run nim manually with `--noLinking:on|off`"
  let (zigcc, zigcpp) = nim.buildNimZ(force=force) # Get the NimZ aliases. Build them when they do not exist
  var zigTarget :string= " "
  zigTarget.add &"--nimcache:{cfg.cacheDir.path} "
  if obj.syst != getHost():
    let zigSyst = obj.syst.toZig
    let nimSyst = obj.syst.toNim
    zigTarget.add &"--os:{nimSyst.os} --cpu:{nimSyst.cpu} "
    zigTarget.add &"--passC:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
    zigTarget.add &"--passL:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
  let typFlag = case obj.kind
    of SharedLibrary : "--app:lib"
    of StaticLibrary : "--app:staticlib"
    else             : ""
  let verb = if cfg.verbose: "--verbosity:3" elif cfg.quiet: "--hints:off" else:""
  var nim = nim.getRealBin()
  var nimOpts = &" {verb} {typFlag} "
  if force: nimOpts &= " -f"
  let nimBackend = cfg.nim.backend
  case  obj.cc  # Add extra parameters for the compilers when required
  of    Zig:    nim = fmt( nimz.CCTempl ) & nimOpts & zigTarget
  of    GCC:    nim &= " --cc:gcc"
  of    Clang:  nim &= " --cc:clang"
  if cfg.nim.unsafe.functionPointers: nim.add " --passC:-Wno-incompatible-function-pointer-types"
  let paths = obj.deps.to(Nim)
  let cmd = &"{nim} --out:{obj.trg.toBin(obj.syst.os).path} --outdir:\"{path obj.root/obj.sub}\" {paths} {obj.args} {obj.src.join()}"
  if cfg.verbose     : echo cmd
  elif not cfg.quiet : echo &"{cfg.Cstr} {obj.trg}"
  sh cmd

