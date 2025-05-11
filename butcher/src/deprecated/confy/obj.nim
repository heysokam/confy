#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps ndk
import nstd/paths
# @deps confy
import ./cfg
import ./types
import ./tool/helper as t
import ./builder/helper
import ./dirs
import ./info



#_____________________________
proc new *(_ :typedesc[BuildTrg];
    src     : seq[DirFile];
    trg     : Path | string = Path("");
    kind    : BinKind       = Program;
    cc      : Compiler      = Zig;
    flags   : Flags         = cfg.flags(C);
    syst    : System        = getHost();
    root    : Dir           = Dir("");
    sub     : Dir           = Dir("");
    remotes : seq[Path]     = @[];
    deps    : Dependencies  = Dependencies();
    args    : string        = "";
    version : string        = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  # note: Main constructor logic unified here. Other constructors should call this one.
  #     : Exposed for ergonomics, but not needed by the user.
  if verbose: cfg.quiet = off  # Disable quiet when verbose is active.
  let rDir   = if root.string == "": cfg.binDir elif root.isAbsolute: root else: cfg.binDir/root
  let lang   = src.getLang()
  let target :Path=
    when trg is string:
      if trg == "": src[0].file.lastPathPart().Path
      else: trg.Path
    else:
      if trg == Path"": src[0].file.lastPathPart()
      else: trg
  BuildTrg(
    kind  : kind,  src     : src,     trg     : target,
    cc    : cc,    flags   : flags,   syst    : syst,
    root  : rDir,  sub     : sub,     remotes : remotes,
    deps  : deps,  args  : args,  version : version, lang    : lang,
    ) # << BuildTrg( ... )
#_____________________________
proc new *(kind :BinKind;
    src     : seq[DirFile];
    trg     : Path | string = Path("");
    cc      : Compiler      = Zig;
    flags   : Flags         = cfg.flags(C);
    syst    : System        = getHost();
    root    : Dir           = cfg.binDir;
    sub     : Dir           = Dir("");
    remotes : seq[Path]     = @[];
    deps    : Dependencies  = Dependencies();
    args    : string        = "";
    version : string        = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src, trg, kind, cc, flags, syst, root, sub, remotes, deps, args, version)
#_____________________________
proc new *(kind :BinKind;
    src     : seq[Path];
    trg     : Path | string = Path("");
    cc      : Compiler      = Zig;
    flags   : Flags         = cfg.flags(C);
    syst    : System        = getHost();
    root    : Dir           = cfg.binDir;
    sub     : Dir           = Dir("");
    remotes : seq[Path]     = @[];
    deps    : Dependencies  = Dependencies();
    args    : string        = "";
    version : string        = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src.toDirFile, trg, kind, cc, flags, syst, root, sub, remotes, deps, args, version)
#_____________________________
proc new *(kind :BinKind;
    src     : Path;
    trg     : Path | string = Path("");
    cc      : Compiler      = Zig;
    flags   : Flags         = cfg.flags(C);
    syst    : System        = getHost();
    root    : Dir           = cfg.binDir;
    sub     : Dir           = Dir("");
    remotes : seq[Path]     = @[];
    deps    : Dependencies  = Dependencies();
    args    : string        = "";
    version : string        = "";
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(@[src.Fil.toDirFile], trg, kind, cc, flags, syst, root, sub, remotes, deps, args, version)

