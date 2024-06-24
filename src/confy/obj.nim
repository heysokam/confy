#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/paths as std import nil
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
    src     : PathList;
    trg     : Fil | string = newEmpty Fil;
    kind    : BinKind      = Program;
    cc      : Compiler     = Zig;
    flags   : Flags        = cfg.flags(C);
    syst    : System       = getHost();
    root    : Dir          = newEmpty Dir;
    sub     : Dir          = newEmpty Dir;
    remotes : PathList     = @[];
    deps    : Dependencies = Dependencies();
    args    : string       = "";
    version : Version      = Version();
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  # note: Main constructor logic unified here. Other constructors should call this one.
  #     : Exposed for ergonomics, but not needed by the user.
  if verbose: cfg.quiet = off  # Disable quiet when verbose is active.
  let rDir   = if root.path == "": cfg.binDir elif root.isAbsolute: root else: cfg.binDir/root
  let lang   = src.getLang()
  let target :Fil=
    when trg is string:
      if trg == "" : src[0].chgDir(cfg.binDir).changeExt("")
      else         : paths.newFile(os.splitFile(trg).dir, os.splitFile(trg).name, os.splitFile(trg).ext, sub="")
    else:
      if trg == UndefinedPath: src[0].chgDir(cfg.binDir).changeExt("")
      else: trg
  BuildTrg(
    kind  : kind,  src   : src,   trg     : target,
    cc    : cc,    flags : flags, syst    : syst,
    root  : rDir,  sub   : sub,   remotes : remotes,
    deps  : deps,  args  : args,  version : version, lang : lang,
    ) # << BuildTrg( ... )
#_____________________________
proc new *(kind :BinKind;
    src     : PathList;
    trg     : Fil | string = newEmpty Fil;
    cc      : Compiler     = Zig;
    flags   : Flags        = cfg.flags(C);
    syst    : System       = getHost();
    root    : Dir          = cfg.binDir;
    sub     : Dir          = newEmpty Dir;
    remotes : PathList     = @[];
    deps    : Dependencies = Dependencies();
    args    : string       = "";
    version : Version      = Version();
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src, trg, kind, cc, flags, syst, root, sub, remotes, deps, args, version)
#_____________________________
proc new *(kind :BinKind;
    src     : seq[std.Path];
    trg     : Fil | string = newEmpty Fil;
    cc      : Compiler     = Zig;
    flags   : Flags        = cfg.flags(C);
    syst    : System       = getHost();
    root    : Dir          = cfg.binDir;
    sub     : Dir          = Dir.new("");
    remotes : PathList     = @[];
    deps    : Dependencies = Dependencies();
    args    : string       = "";
    version : Version      = Version();
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src.toPaths, trg, kind, cc, flags, syst, root, sub, remotes, deps, args, version)
#_____________________________
proc new *(kind :BinKind;
    src     : Fil;
    trg     : Fil | string = newEmpty Fil;
    cc      : Compiler     = Zig;
    flags   : Flags        = cfg.flags(C);
    syst    : System       = getHost();
    root    : Dir          = cfg.binDir;
    sub     : Dir          = Dir.new("");
    remotes : PathList     = @[];
    deps    : Dependencies = Dependencies();
    args    : string       = "";
    version : Version      = Version();
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(@[src.toPath], trg, kind, cc, flags, syst, root, sub, remotes, deps, args, version)

#_____________________________
proc print *(obj :BuildTrg) :void=  info.report(obj)
  ## Prints all contents of the object to the command line.

