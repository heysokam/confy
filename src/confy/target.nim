#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`, splitFile
from std/strformat import fmt
# @deps confy
import ./types/base
import ./types/errors
import ./types/config as types_config
import ./types/build as types
import ./tools/version as V
import ./tools/files as F
from   ./log import fail, verb, warn
import ./lang
import ./command
import ./dependency
import ./flags as confy_flags
from ./systm as sys import nil
from ./cfg as config import nil
from ./state as G import nil

export types.Build

#_______________________________________
# @section Config: Update
#_____________________________
func updateSystemBin *(cfg :Config) :Config=
  result = cfg
  if result.zig.systemBin    : result.zig.bin    = config.zig_bin
  if result.nim.systemZigCC  : result.zig.cc     = config.zig_cc
  if result.nim.systemZigCC  : result.zig.cpp    = config.zig_cpp
  if result.nim.systemZigCC  : result.zig.ar     = config.zig_ar
  if result.nim.systemBin    : result.nim.bin    = config.nim_bin
  if result.nimble.systemBin : result.nimble.bin = config.nimble_bin


#_______________________________________
# @section BuildTarget: Information Report
#_____________________________
const NoValue          = "..."
const Templ_TargetInfo = """
{obj.cfg.prefix} Building {obj.kind} | {obj.trg} from folder `{obj.cfg.dirs.root}`:
  Version:          {version}
  Target Binary:    {sys.binary(obj)}
  Target Platform:  {obj.system.os}
  Target Arch:      {obj.system.cpu}
  Host Platform:    {sys.host().os}
  Host Arch:        {sys.host().cpu}
  Language:         {obj.lang}
  Flags.cc:         {obj.flags.cc}
  Flags.ld:         {obj.flags.ld}
  Remotes:          {remotes}
  Code Subdir:      {subdir}
  Code file list:   {obj.src}
"""
func report *(
    obj   : BuildTarget;
    templ : static string= Templ_TargetInfo;
  ) :void=
  ## @descr Reports information about the {@link BuildTarget} object on CLI.
  if not obj.cfg.verbose: return
  let remotes = NoValue
  # let remotes = if obj.remotes.len > 0  : $obj.remotes  else: NoValue
  let version = if $obj.version != ""   : $obj.version  else: NoValue
  let subdir  = if obj.sub.string != "" : $obj.sub      else: NoValue
  debugEcho fmt( templ )


#_______________________________________
# @section BuildTarget: Create
#_____________________________
func entry *(trg :var BuildTarget; file :PathLike) :PathLike=
  if trg.src.len == 0 : ""
  else                : trg.src[0]
#___________________
func `entry=` *(trg :var BuildTarget; file :PathLike) :void=
  if trg.src.len == 0 : trg.src.add file
  else                : trg.src[0] = file
#___________________
func new *(kind :Build;
    entry   : PathLike     = "";
    cfg     : Config       = G.cfg;
    src     : SourceList   = @[];
    trg     : PathLike     = NullPath;
    version : Version      = Version();
    sub     : PathLike     = "";
    lang    : Lang         = Lang.Unknown;
    deps    : Dependencies = @[];
    flags   : Flags        = Flags();
    args    : ArgsList     = @[];
    system  : System       = sys.host();
    remotes : Remotes      = Remotes.with(G.cfg.dirs.src);
  ) :BuildTarget=
  ## @descr
  ##  Creates a new {@link BuildTarget} object containing all the data needed by confy to build the given binary {@arg kind}
  ##  Any arguments omitted will be automatically resolved to sane defaults.
  ## @example
  ##  ```nim
  ##  let app = Program.new("hello.c")
  ##  ```
  # Base config
  result     = BuildTarget(kind: kind, version: version)
  result.cfg = cfg.updateSystemBin()
  # Merge the source code, and adjust it based on the remotes
  result.src = if entry != "": @[result.cfg.dirs.src/entry] & src else: src
  let R = Remotes.with(result.cfg.dirs.src).merge(remotes)
  if R.autoAdjust: result.src = R.adjust(result.src, root=result.cfg.dirs.src)
  # Get the rest of the options
  result.trg    = if trg == NullPath: entry.splitFile().name else: trg
  result.sub    = sub
  result.lang   = if lang != Lang.Unknown: lang else: Lang.identify(result.src)
  result.deps   = deps
  result.args   = args
  result.system = system
  # Add the flags
  let flags_default = case result.lang
    of C   : confy_flags.C
    of Cpp : confy_flags.Cpp
    else   : @[]
  result.flags = Flags(cc: flags_default, ld: flags.ld)
  for flag in flags.cc:
    if flag notin result.flags.cc: result.flags.cc.add flag


#_______________________________________
# @section BuildTarget: Order to Build
#_____________________________
func build *(trg :BuildTarget) :BuildTarget {.discardable.}=
  trg.download(Dependencies)
  trg.report()
  let cmd = Command.build(trg)
  if sys.exec(cmd) != 0: trg.fail CompileError, "Failed to build the target:\n  ", $trg
  result = trg
#___________________
func cross *(
    trg  : BuildTarget;
    syst : System;
  ) :BuildTarget {.discardable.}=
  # Guard clause to regular build when not cross-compiling a target
  const host = sys.host()
  if trg.system == host and syst == host: return trg.build()
  # Cross Compile
  result = trg
  result.system = syst
  result.report()
  let cmd = Command.build(result)
  if sys.exec(cmd) != 0: result.fail CompileError, "Failed to cross-compile {$result}  for  {$syst}"
#___________________
func buildFor *(
    trg     : BuildTarget;
    systems : openArray[System];
  ) :seq[BuildTarget] {.discardable.}=
  if systems.len == 0: return @[]
  trg.download(Dependencies)
  for syst in systems: result.add trg.cross(syst)

#_______________________________________
# @section BuildTarget: Order to Run
#_____________________________
func run *(trg :BuildTarget) :BuildTarget {.discardable.}=
  let cmd  = Command.run(trg)
  let code = sys.exec(cmd)
  if code != 0: trg.warn "Run command exited with code:", $code
  else        : trg.verb "Done running. Command exited with code:", $code
  result = trg

