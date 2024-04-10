#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview Base internal funcionality for all builder modules
#___________________________________________________________________|
# @deps std
import std/os
import std/sequtils
# @deps ndk
import nstd/strings
# @deps confy
import ../types
import ../cfg
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
  ## @descr Builds the `src` file directly into the `trg` file.
  ## @note Doesn't compile an intermediate `.o` step, unless the CC command includes the "-c" option.
  let flg = flags.join(" ")
  let cmd = &"{CC} {flg} {src.path} -o {trg}"
  if cfg.quiet : echo &"{quietStr} {trg}"
  sh cmd, cfg.verbose
  if helper.isBin(trg): trg.setExec()  # Set executable flags on the resulting binary.
#___________________
proc direct *(
    src      : seq[DirFile];
    trg      : Fil;
    CC       : string;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## @descr Builds the `src` list of files directly into the `trg` file.
  ## @note Doesn't compile an intermediate `.o` step.
  let files = src.mapIt(it.path.string).join(" ")
  let flg   = flags.join(" ")
  let cmd   = &"{CC} {flg} {files} -o {trg}"
  if not quiet: echo &"{quietStr} {trg}"
  elif verbose: echo cmd
  else:         log &"Compiling {trg} ..."
  sh cmd, cfg.verbose
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
  ## @descr Links the given `src` list of files into the `trg` binary.
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
    syst     : System;
    CC       : Compiler;
    flags    : Flags;
    quietStr : string;
  ) :seq[DirFile] {.discardable.}=
  ## @descr Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  ## @returns The list of compiled files.
  for file in src:
    let trg = file.chgDir(dir).path.toObj(syst.os)
    file.direct(trg, file.getCC(CC) & " -c", flags.cc, quietStr)
    result.add DirFile.new(dir, trg.string.replace(dir.string, ""))
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
