#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps ndk
import nstd/strings
import nstd/paths
# @deps confy
import ../types
import ../cfg
import ../dirs
import ../tool/helper as t
# @deps confy.builder
import ./base
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/zcfg


#_______________________________________
# Configuration
#_____________________________
proc getTarget *(syst :System) :string=
  ## @descr Returns a `-target cpu-os` flag for sending it to zigcc for cross-compilation.
  if syst == getHost(): return ""
  let zigSyst = helper.toZig(syst)
  result = &"-target {zigSyst.cpu}-{zigSyst.os}"
  if syst.os == Linux: result.add "-gnu"

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

