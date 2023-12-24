#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
# @deps confy
import ../types
import ../cfg
# @deps confy.builder
import ./base
# @deps confy.builder.zigcc
import ./zigcc/zcfg


#_______________________________________
# Configuration
#_____________________________
proc getCC *(src :DirFile) :string=
  ## @descr Gets the correct CC command for the given source file extension.
  case src.file.string.splitFile.ext
  of ".c":           result = zcfg.getRealCC()
  of ".cpp", ".cc":  result = zcfg.getRealCCP()
  else:              result = "echo"
#___________________
proc getCC *(src :seq[DirFile]) :string=
  ## @descr Gets the correct CC command for the given source files list extension.
  var cmds :seq[string]
  for file in src:  cmds.add file.getCC
  if zcfg.getRealCCP() in cmds:   return zcfg.getRealCCP()
  else:                           return zcfg.getRealCC()


#_____________________________
# Direct compilation
#___________________
proc direct * (src :DirFile; trg :Fil; flags :seq[string]; quietStr :string) :void=
  ## @descr Builds the `src` file directly into the `trg` file.
  ## @note Doesn't compile an intermediate `.o` step, unless the CC command includes the "-c" option.
  base.direct(src,trg, src.getCC, flags, quietStr)
#___________________
proc direct * (src :seq[DirFile]; trg :Fil; flags :seq[string]; quietStr :string) :void=
  ## @descr Builds the `src` list of files directly into the `trg` file.
  ## @note Doesn't compile an intermediate `.o` step.
  base.direct(src,trg, src.getCC, flags, quietStr)

#_____________________________
# ZigCC: Linker
#___________________
proc link *(src :seq[DirFile]; trg :Fil; lang :Lang; flags :Flags) :void=
  ## @descr Links the given `src` list of files into the `trg` binary.
  base.link(src, trg, lang, Zig, flags)

#_____________________________
# ZigCC: Compiler
#___________________
proc compileNoObj *(src :seq[DirFile]; trg :Fil; flags :Flags) :void=
  ## @descr Compiles the given `src` list of files using the given CC into the `trg` binary.
  ## @note Doesn't compile an intermediate `.o` step.
  base.compileNoObj(src, trg, Zig, flags, cfg.Cstr)
#___________________
proc compileToObj *(src :seq[DirFile]; dir :Dir; flags :Flags) :void=
  ## @descr Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  base.compileToObj(src, dir, Zig, flags, cfg.Cstr)
#___________________
proc compileToMod *(src :seq[DirFile]; dir :Dir; flags :Flags) :void=
  ## @descr Compiles the given `src` list of files as named modules, and outputs them into the `dir` folder.
  base.compileToMod(src, dir, Zig, flags, cfg.Cstr)

#___________________
proc compile *(src :seq[DirFile]; trg :Fil; root :Dir; syst :System; flags :Flags) :void=
  ## @descr Compiles the given `src` list of files using `ZigCC`
  ## @note Assumes the paths given are already relative/absolute in the correct way.
  base.compile(src, trg, root, syst, Zig, flags, cfg.Cstr)
#___________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool) :void=
  base.compile(src, obj, Zig, cfg.Cstr)


