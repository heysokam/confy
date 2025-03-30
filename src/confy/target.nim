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
from   ./log import fail, verb, warn

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
  if cmd.exec() != 0: trg.fail CompileError, "Failed to build the target:\n  ", trg.repr
  result = trg


func run *(trg :BuildTarget) :BuildTarget {.discardable.}=
  let cmd  = Command.run(trg)
  let code = cmd.exec()
  if code != 0: trg.warn "Run command exited with code:", $code
  else        : trg.verb "Done running. Command exited with code:", $code
  result = trg

