#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`
# @deps confy
import ./types/build {.all.}
import ./flags


func c *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.zig.bin
  result.parts.add "cc"
  # Flags
  result.parts &= flags.C


func cpp *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.zig.bin
  result.parts.add "c++"
  # Flags
  result.parts &= flags.Cpp


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
  # Output
  result.parts.add "-femit-bin=" & trg.cfg.dirs.bin/trg.cfg.dirs.sub/trg.trg


func nim *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.parts.add trg.cfg.nim.bin
  result.parts.add $trg.cfg.nim.backend
  # Cache
  # Flags
  result.parts &= @[]


func build *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  result = case trg.lang
    of Lang.C   : Command.c(trg)
    of Lang.Zig : Command.zig(trg)
    of Lang.Cpp : Command.cpp(trg)
    of Lang.Nim : Command.nim(trg)
    else:Command()

