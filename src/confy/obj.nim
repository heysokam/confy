#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/paths
# confy dependencies
import ./types
import ./cfg as c


proc new *(_ :typedesc[BuildTrg];
    src   : seq[Path];
    trg   : Path     = Path("");
    kind  : BinKind  = Program;
    root  : Dir      = Dir("");
    flags : Flags    = c.flags;
    cc    : Compiler = Zig;
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  let rDir = if root.string == "": c.binDir elif root.isAbsolute: root else: c.binDir/root
  echo rDir
  BuildTrg(kind: kind, src: src, trg: trg, flags: flags, root: rDir, cc: cc)

proc new *(kind :BinKind;
    src   : seq[Path];
    trg   : Path     = Path("");
    root  : Dir      = c.binDir;
    flags : Flags    = c.flags;
    cc    : Compiler = Zig;
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src, trg, kind, root, flags, cc)

proc setup *(obj :BuildTrg) :void=  discard
  ## Setup the object data to be ready for compilation.
proc clone *(obj :BuildTrg) :BuildTrg=  result = obj
  ## Returns a copy of the object, so it can be duplicated.
proc print *(obj :BuildTrg) :void=  echo obj
  ## Prints all contents of the object to the command line.

