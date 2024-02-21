#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/strformat
# @deps confy
import ../types
import ../cfg
import ../dirs
import ../tool/helper as t
import ../tool/paths
# @deps confy.builder
import ./base
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/zcfg


#_______________________________________
# Configuration
#_____________________________
proc getCC *(lang :Lang) :string=
  ## @descr Gets the correct CC command for the given source file extension.
  case lang
  of C   : result = zcfg.getRealCC()
  of Cpp : result = zcfg.getRealCCP()
  else   : result = "echo"
#___________________
proc getCC *(src :seq[DirFile]) :string=
  ## @descr Gets the correct CC command for the given source files list extension.
  var cmds :seq[string]
  for file in src:  cmds.add file.getLang.getCC
  if zcfg.getRealCCP() in cmds : return zcfg.getRealCCP()
  else                         : return zcfg.getRealCC()

#_____________________________
proc getTarget *(syst :System) :string=
  ## @descr Returns a `-target cpu-os` flag for sending it to zigcc for cross-compilation.
  if syst == getHost(): return ""
  let zigSyst = helper.toZig(syst)
  result = &"-target {zigSyst.cpu}-{zigSyst.os}"

#_____________________________
# ZigCC: Compiler
#___________________
proc compileStatic *(
    src      : seq[DirFile];
    trg      : Fil;
    root     : Dir;
    CC       : Compiler;
    flags    : Flags;
    syst     : System;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files as a SharedLibrary, using the given `CC` command.
  ## Assumes the paths given are already relative/absolute in the correct way.
  let objs = src.compileToObj(root, syst, CC, flags, quietStr).join()
  let verb = if cfg.verbose: "v" else: ""
  let ar = (root/trg).toAR(syst.os)
  sh &"{zcfg.getRealAR()} -rc{verb} {ar} {objs}", cfg.verbose
#___________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool) :void=
  ## @descr Compiles the given `src` list of files with ZigCC.
  case obj.kind
  of Program:        base.direct(src, obj.root/obj.sub/obj.trg.toBin(obj.syst.os), src.getCC, obj.flags.cc & obj.flags.ld & @[obj.syst.getTarget()], cfg.Cstr)
  of Object:         base.compileToObj(src, obj.root, obj.syst, Zig, obj.flags, cfg.Cstr)
  of SharedLibrary:  base.direct(src, obj.root/obj.sub/obj.trg.toLib(obj.syst.os), src.getCC, obj.flags.cc & obj.flags.ld & @["-shared"], cfg.Cstr)  # base.compileShared(src, obj.trg, Zig, obj.root, obj.flags, obj.syst, cfg.Cstr)
  of StaticLibrary:  zigcc.compileStatic(src, obj.trg, obj.root, Zig, obj.flags, obj.syst, cfg.Cstr)
  # of Module:         base.compileToMod(src, obj.root, obj.flags)
  else: return

