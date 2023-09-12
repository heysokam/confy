#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# GCC and Clang specific builder.  |
#__________________________________|
# std dependencies
# confy dependencies
import ../types
import ../cfg
import ../flags as fl
# Builder Module dependencies
import ./base
import ./helper


#_____________________________
# GCC/Clang: Internal
#___________________
proc direct *(
    src      : DirFile;
    trg      : Fil;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## Builds the `src` file directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  base.direct(src, trg, src.getCC(GCC), flags, quietStr)
#___________________
proc direct *(
    src      : seq[DirFile];
    trg      : Fil;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## Builds the `src` list of files directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  base.direct(src, trg, src.getCC(GCC), flags, quietStr)

#_____________________________
# GCC/Clang: Linker
#___________________
proc link *(
    src   : seq[DirFile];
    trg   : Fil;
    lang  : Lang;
    flags : Flags = fl.allPP;
  ) :void=
  ## Links the given `src` list of files into the `trg` binary.
  base.link(src, trg, lang, GCC, flags)

#_____________________________
# GCC/Clang: Compiler
#___________________
proc compileNoObj *(
    src      : seq[DirFile];
    trg      : Fil;
    flags    : Flags = fl.allPP;
    quietStr : string = Cstr
  ) :void=
  ## Compiles the given `src` list of files using `gcc` into the `trg` binary.
  ## Doesn't compile an intermediate `.o` step.
  base.compileNoObj(src, trg, GCC, flags, quietStr)
#___________________
proc compileToObj *(
    src      : seq[DirFile];
    dir      : Dir;
    flags    : Flags  = fl.allPP;
    quietStr : string = Cstr
  ) :void=
  ## Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  base.compileToObj(src, dir, GCC, flags, quietStr)
#___________________
proc compileToMod *(
    src      : seq[DirFile];
    dir      : Dir;
    flags    : Flags  = fl.allPP;
    quietStr : string = Cstr;
  ) :void=
  ## Compiles the given `src` list of files as named modules, and outputs them into the `dir` folder.
  base.compileToMod(src, dir, GCC, flags, quietStr)
#___________________
proc compile *(
    src      : seq[DirFile];
    trg      : Fil;
    root     : Dir;
    syst     : System;
    flags    : Flags  = fl.allPP;
    quietStr : string = Cstr;
  ) :void=
  ## Compiles the given `src` list of files using `gcc`
  ## Assumes the paths given are already relative/absolute in the correct way.
  base.compile(src, trg, root, syst, GCC, flags, quietStr)
#___________________
proc compileShared *(
    src      : seq[DirFile];
    trg      : Fil;
    root     : Dir;
    syst     : System;
    flags    : Flags = fl.allPP;
    quietStr : string = Cstr;
  ) :void=
  ## Compiles the given `src` list of files as a SharedLibrary, using `gcc`.
  ## Assumes the paths given are already relative/absolute in the correct way.
  base.compileShared(src, trg, root, GCC, flags, syst, quietStr)
#___________________
proc compile *(
    src      : seq[DirFile];
    obj      : BuildTrg;
  ) :void=
  case obj.kind
  of Program:        src.compile(obj.trg, obj.root, obj.syst, GCC, obj.flags, cfg.Cstr)
  of Object:         src.compileToObj(obj.root, GCC, obj.flags, cfg.Cstr)
  of Module:         src.compileToMod(obj.root, GCC, obj.flags, cfg.Cstr)
  of SharedLibrary:  src.compileShared(obj.trg, obj.root, GCC, obj.flags, obj.syst, cfg.Cstr)
  of StaticLibrary:  raise newException(CompileError, "Compiling as StaticLibrary is not implemented with GCC.")

