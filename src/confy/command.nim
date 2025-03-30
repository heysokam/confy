#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`, execShellCmd
from std/strutils import join
# @deps confy
import ./types/base
import ./types/build
import ./log
from ./flags import nil

func getBinary *(trg :BuildTarget) :PathLike= trg.cfg.dirs.bin/trg.cfg.dirs.sub/trg.trg

func exec *(cmd :Command) :int {.discardable.}=
  log.info "Executing command:\n  ", cmd.parts.join(" ")
  return os.execShellCmd cmd.parts.join(" ")


func c *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.zig.bin
  result.parts.add "cc"
  # Options
  if trg.cfg.verbose: result.parts.add "-v"
  # Flags
  result.parts &= flags.C
  # Source code
  result.parts &= trg.src
  # Output
  result.parts.add "-o"
  result.parts.add trg.getBinary()


func cpp *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.zig.bin
  result.parts.add "c++"
  # Flags
  result.parts &= flags.Cpp
  # Source code
  result.parts &= trg.src
  # Output
  result.parts.add "-o"
  result.parts.add trg.getBinary()


func zig *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.nim.bin
  case trg.kind
  of SharedLib,
     StaticLib : result.parts.add "build-lib"
  of Program   : result.parts.add "build-exe"
  of UnitTest  : result.parts.add "test"
  else:discard
  # Cache
  result.parts &= [       "--cache-dir", trg.cfg.zig.cache]
  result.parts &= ["--global-cache-dir", trg.cfg.zig.cache]
  # Flags
  if trg.kind == Program: result.parts.add "-freference-trace"
  # Source code
  result.parts &= trg.src
  # Output
  result.parts.add "-femit-bin=" & trg.getBinary()


func nim *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.nim.bin
  result.parts.add $trg.cfg.nim.backend
  # Cache
  # Flags
  result.parts &= @[]
  # Source code
  result.parts &= trg.src
  # Output


func build *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  result = case trg.lang
    of Lang.C   : Command.c(trg)
    of Lang.Zig : Command.zig(trg)
    of Lang.Cpp : Command.cpp(trg)
    of Lang.Nim : Command.nim(trg)
    else:Command()


func run *(_:typedesc[Command];
    trg   :BuildTarget;
    args  :CommandParts= @[];
  ) :Command=
  result = Command()
  result.parts.add trg.getBinary()
  result.parts &= args

