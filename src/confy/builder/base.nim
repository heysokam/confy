#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview Base internal funcionality for all builder modules
#___________________________________________________________________|
# @deps std
import std/os
import std/strformat
import std/sequtils
# @deps confy
import ../types
import ../cfg
import ../tool/strings
import ../tool/helper as t
import ../tool/logger
import ../dirs
# @deps confy.builder
import ./helper


#_____________________________
# Direct compilation
#___________________
proc direct *(
    src      : DirFile;
    trg      : Fil;
    CC       : string;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## Builds the `src` file directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step, unless the CC command includes the "-c" option.
  let flg = flags.join(" ")
  let cmd = &"{CC} {flg} {src.path} -o {trg}"
  if cfg.quiet : echo &"{quietStr} {trg}"
  else         : echo cmd
  sh cmd
  if helper.isBin(trg): trg.setExec()  # Set executable flags on the resulting binary.
#___________________
proc direct *(
    src      : seq[DirFile];
    trg      : Fil;
    CC       : string;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## Builds the `src` list of files directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  let files = src.mapIt(it.path.string).join(" ")
  let flg   = flags.join(" ")
  let cmd   = &"{CC} {files} {flg} -o {trg}"
  if not quiet: echo &"{quietStr} {trg}"
  elif verbose: echo cmd
  else:         log &"Linking {trg} ..."
  sh cmd
  if helper.isBin(trg): trg.setExec()  # Set executable flags on the resulting binary.

#_____________________________
# Base: Linker
#___________________
proc link *(
    src   : seq[DirFile];
    trg   : Fil;
    lang  : Lang;
    CC    : Compiler;
    flags : Flags;
  ) :void=
  ## Links the given `src` list of files into the `trg` binary.
  direct(src, trg, lang.getCC(CC), flags.ld, Lstr)

#_____________________________
# Base: Compiler
#___________________
proc compileNoObj *(
    src      : seq[DirFile];
    trg      : Fil;
    CC       : Compiler;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files using the given CC into the `trg` binary.
  ## Doesn't compile an intermediate `.o` step.
  direct(src, trg, src.getCC(CC), flags.cc, quietStr)
#___________________
proc compileToObj *(
    src      : seq[DirFile];
    dir      : Dir;
    CC       : Compiler;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  for file in src:
    let trg = file.chgDir(dir).path.string.changeFileExt(".o").Fil
    file.direct(trg, file.getCC(CC) & " -c", flags.cc, quietStr)
#___________________
proc compileToMod *(
    src      : seq[DirFile];
    dir      : Dir;
    CC       : Compiler;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files as named modules, and outputs them into the `dir` folder.
  for file in src:
    let trg = file.chgDir(dir).path.string.changeFileExt(".pcm").Fil
    file.direct(trg, file.getCC(CC) & " -c", flags.cc, quietStr)

#___________________
proc compile *(
    src      : seq[DirFile];
    trg      : Fil;
    root     : Dir;
    syst     : System;
    CC       : Compiler;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files using the given `CC` command.
  ## Assumes the paths given are already relative/absolute in the correct way.
  var objs :seq[DirFile]
  # var cmds :seq[string]
  var cfl  = flags.cc.join(" ")
  log &"Building {trg} ..."
  if quiet: stdmsg.write &"{tab}|" # add | to start the line of the silent case
  for file in src:
    if file.path.isObj:  # File is already an object. Add to objs and continue
      objs.add(file); continue
    let trg = DirFile.new(file.dir, file.file.toObj(syst.os)).chgDir(root)
    let dir = trg.path.string.splitFile.dir
    let cmd = &"{file.getCC(CC)} -MMD {cfl} -c {file.path} -o {trg.path}"
    if   quiet:   stdmsg.write "."
    elif verbose: echo cmd
    else:         echo &"{quietStr} {trg.path}"
    objs.add trg
    if not dir.dirExists: createDir dir
    sh cmd
    # cmds.add cmd
  if quiet: echo "Done." # add \n to end the line of the silent case
  # sh cmds, cfg.cores
  objs.link(trg, src.getLang(), CC, flags)
#___________________
proc compileShared *(
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
  src.compile(trg.toLib(syst.os), root, syst, CC, Flags(cc: flags.cc, ld: flags.ld & "-shared"), quietStr)

#___________________
proc compile *(
    src      : seq[DirFile];
    obj      : BuildTrg;
    CC       : Compiler;
    quietStr : string;
  ) :void=
  case obj.kind
  of Program:        src.compile(obj.trg, obj.root, obj.syst, CC, obj.flags, quietStr)
  of Object:         src.compileToObj(obj.root, CC, obj.flags, quietStr)
  of Module:         src.compileToMod(obj.root, CC, obj.flags, quietStr)
  of SharedLibrary:  src.compileShared(obj.trg, obj.root, CC, obj.flags, obj.syst, quietStr)
  of StaticLibrary:  raise newException(CompileError, "Compiling as StaticLibrary is not implemented.")

