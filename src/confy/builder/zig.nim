#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
# confy dependencies
import ../types
import ../auto
import ../cfg
import ./base
# zig dependencies
import ./zig/json
import ./zig/zcfg as zcfg
import ./zig/bin

#_______________________________________
# Configuration
#_____________________________
proc setCC *(trg :Fil) :void=
  ## Sets the cc and cpp compiler commands, based on the given zig input binary.
  zcfg.cc  = trg & " cc"
  zcfg.ccp = trg & " c++"
#___________________
proc getCC *(src :Fil) :string=
  ## Gets the correct CC command for the given source file extension.
  case src.splitFile.ext
  of ".c":           result = zcfg.cc
  of ".cpp", ".cc":  result = zcfg.ccp
  else:              result = "echo"
#___________________
proc getCC *(src :seq[Fil]) :string=
  ## Gets the correct CC command for the given source files list extension.
  var cmds :seq[string]
  for file in src:  cmds.add file.getCC
  if ccp in cmds:   return ccp
  else:             return cc
#_____________________________
# Setup/Download
#___________________
proc initOrExists *() :bool=  bin.initOrExists()
  ## Initializes the zig compiler binary, or returns true if its already initialized.



#_____________________________
# Direct compilation
#___________________
proc direct * (src :Fil; trg :Fil; flags :seq[string]; quietStr :string) :void=
  ## Builds the `src` file directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step, unless the CC command includes the "-c" option.
  base.direct(src,trg, src.getCC, flags, quietStr)
#___________________
proc direct * (src :seq[Fil]; trg :Fil; flags :seq[string]; quietStr :string) :void=
  ## Builds the `src` list of files directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  base.direct(src,trg, src.getCC, flags, quietStr)

#_____________________________
# GCC: Linker
#___________________
proc link *(src :seq[Fil]; trg :Fil; flags :Flags) :void=
  ## Links the given `src` list of files into the `trg` binary.
  base.link(src, trg, src.getCC, flags)

#_____________________________
# GCC: Compiler
#___________________
proc compileNoObj *(src :seq[Fil]; trg :Fil; flags :Flags) :void=
  ## Compiles the given `src` list of files using the given CC into the `trg` binary.
  ## Doesn't compile an intermediate `.o` step.
  base.compileNoObj(src, trg, src.getCC, flags, cfg.Cstr)
#___________________
proc compileToObj *(src :seq[Fil]; dir :Dir; flags :Flags) :void=
  ## Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  base.compileToObj(src, dir, src.getCC, flags, cfg.Cstr)
#___________________
proc compileToMod *(src :seq[Fil]; dir :Dir; flags :Flags) :void=
  ## Compiles the given `src` list of files as named modules, and outputs them into the `dir` folder.
  base.compileToMod(src, dir, src.getCC, flags, cfg.Cstr)

#___________________
proc compile *(src :seq[Fil]; trg :Fil; flags :Flags) :void=
  ## Compiles the given `src` list of files using `gcc`
  ## Assumes the paths given are already relative/absolute in the correct way.
  base.compile(src, trg, src.getCC, flags, cfg.Cstr)
#___________________
proc compile *(src :seq[Fil]; obj :BuildTrg) :void=
  base.compile(src, obj, src.getCC, obj.flags, cfg.Cstr)

