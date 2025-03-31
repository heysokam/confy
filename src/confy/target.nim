#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/paths import Path
# @deps confy
import ./types/base
import ./types/errors
import ./types/config
import ./types/build as types
import ./tools/version as V
from   ./log import fail, verb, warn
import ./lang
import ./command
import ./dependency

export types.Build


func new *(kind :Build;
    entry   : PathLike     = "";
    cfg     : Config       = Config();
    src     : SourceList   = @[];
    trg     : PathLike     = NullPath;
    version : Version      = Version();
    sub     : PathLike     = "";
    lang    : Lang         = Lang.Unknown;
    deps    : Dependencies = @[];
    flags   : Flags        = Flags();
    args    : ArgsList     = @[];
  ) :BuildTarget=
  ## @descr
  ##  Creates a new {@link BuildTarget} object containing all the data needed by confy to build the given binary {@arg kind}
  ##  Any arguments omitted will be automatically resolved to sane defaults.
  ## @example
  ##  ```nim
  ##  const app = Program.new("hello.c")
  ##  ```
  result       = BuildTarget(kind: kind, version: version)
  result.cfg   = cfg
  result.src   = if entry != "": @[entry] & src else: src
  result.trg   = if trg == NullPath: string(paths.splitFile(entry.Path).name) else: trg
  result.sub   = sub
  result.lang  = if lang != Lang.Unknown: lang else: Lang.identify(result.src)
  result.deps  = deps
  result.flags = flags
  result.args  = args


func build *(trg :BuildTarget) :BuildTarget {.discardable.}=
  trg.download(Dependencies)
  let cmd = Command.build(trg)
  if cmd.exec() != 0: trg.fail CompileError, "Failed to build the target:\n  ", $trg
  result = trg


func run *(trg :BuildTarget) :BuildTarget {.discardable.}=
  let cmd  = Command.run(trg)
  let code = cmd.exec()
  if code != 0: trg.warn "Run command exited with code:", $code
  else        : trg.verb "Done running. Command exited with code:", $code
  result = trg

