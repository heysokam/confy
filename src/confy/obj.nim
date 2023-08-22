#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/paths
# confy dependencies
import ./types
import ./cfg
import ./dirs
import ./info
import ./tool/helper
import ./builder/helper



#_____________________________
proc new *(_ :typedesc[BuildTrg];
    src     : seq[DirFile];
    trg     : Path      = Path("");
    kind    : BinKind   = Program;
    cc      : Compiler  = Zig;
    flags   : Flags     = cfg.flags;
    syst    : System    = getHost();
    root    : Dir       = Dir("");
    sub     : Dir       = Dir("");
    remotes : seq[Path] = @[];
    version : string    = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  # note: Main constructor logic unified here. Other constructors should call this one.
  #     : Exposed for ergonomics, but not needed by the user.
  if verbose: cfg.quiet = off  # Disable quiet when verbose is active.
  let rDir = if root.string == "": cfg.binDir elif root.isAbsolute: root else: cfg.binDir/root
  let lang = src.getLang()
  BuildTrg(
    kind    : kind,    src   : src,   trg     : trg,
    cc      : cc,      flags : flags, syst    : syst,
    root    : rDir,    sub   : sub,   remotes : remotes,
    version : version, lang  : lang,
    ) # << BuildTrg( ... )
#_____________________________
proc new *(kind :BinKind;
    src     : seq[DirFile];
    trg     : Path     = Path("");
    cc      : Compiler = Zig;
    flags   : Flags    = cfg.flags;
    syst    : System   = getHost();
    root    : Dir      = cfg.binDir;
    sub     : Dir      = Dir("");
    remotes : seq[Path] = @[];
    version : string = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src, trg, kind, cc, flags, syst, root, sub, remotes, version)
#_____________________________
proc new *(kind :BinKind;
    src     : seq[Path];
    trg     : Path     = Path("");
    cc      : Compiler = Zig;
    flags   : Flags    = cfg.flags;
    syst    : System   = getHost();
    root    : Dir      = cfg.binDir;
    sub     : Dir      = Dir("");
    remotes : seq[Path] = @[];
    version : string = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src.toDirFile, trg, kind, cc, flags, syst, root, sub, remotes, version)
#_____________________________
proc new *(kind :BinKind;
    src     : Path;
    trg     : Path     = Path("");
    cc      : Compiler = Zig;
    flags   : Flags    = cfg.flags;
    syst    : System   = getHost();
    root    : Dir      = cfg.binDir;
    sub     : Dir      = Dir("");
    remotes : seq[Path] = @[];
    version : string = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(@[src.Fil.toDirFile], trg, kind, cc, flags, syst, root, sub, remotes, version)

#_____________________________
proc print *(obj :BuildTrg) :void=  info.report(obj)
  ## Prints all contents of the object to the command line.

