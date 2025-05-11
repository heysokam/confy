
#_____________________________
# Base: Compiler
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
    let trg = (dir/file.path.lastPathPart).toObj(syst.os)
    file.direct(trg, file.getCC(CC) & " -c", flags.cc & flags.ld, quietStr)
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
    let trg = file.chgDir(dir).path.changeFileExt(".pcm").Fil
    file.direct(trg, file.getCC(CC) & " -c", flags.cc, quietStr)

