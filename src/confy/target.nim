#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/paths import Path
# @deps confy
import ./types/errors
import ./types/build as types
import ./lang
import ./command
from   ./log import fail

export types.Build

func new *(kind :Build;
    src :string;
  ) :BuildTarget=
  result      = BuildTarget()
  result.kind = kind
  result.src  = @[src]
  result.trg  = string(paths.splitFile(src.Path).name)
  result.lang = Lang.identify(result.src)


func build *(trg :BuildTarget) :BuildTarget {.discardable.}=
  let cmd = Command.build(trg)
  # log.dbg "Building:", trg.repr
  if cmd.exec() == 0: trg.fail BuildError, "Failed to build the target:\n  ", trg.repr
  result = trg


func run *(trg :BuildTarget) :BuildTarget {.discardable.}=
  # log.dbg "Running:", trg.repr
  let cmd = Command.run(trg)
  cmd.exec()
  result = trg

