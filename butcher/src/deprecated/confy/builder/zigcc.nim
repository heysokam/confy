
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

