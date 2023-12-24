#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
# @deps confy
import ../types
import ../cfg
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
# ZigCC: Compiler
#___________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool) :void=
  ## Compiles the given `src` list of files with ZigCC.
  case obj.kind
  of Program:        base.direct(src,obj.trg, src.getCC, obj.flags.cc & obj.flags.ld, cfg.Cstr)
  # of Object:         base.compileToObj(src, obj.root, obj.flags)
  # of Module:         base.compileToMod(src, obj.root, obj.flags)
  # of SharedLibrary:  base.compileShared(src, obj.trg, obj.root, obj.flags, obj.syst, cfg.Cstr)
  of StaticLibrary:  raise newException(CompileError, "Compiling as StaticLibrary is not implemented.")
  else: return


