#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps confy
import ./types/build {.all.} as types
import ./lang
import ./command
from   ./log import nil

export types.Build

func new *(kind :Build;
    src :string;
  ) :BuildTarget=
  result      = BuildTarget()
  result.kind = kind
  result.src  = @[src]
  result.lang = Lang.identify(result.src)


func build *(trg :BuildTarget) :BuildTarget {.discardable.}=
  result = trg
  let cmd = Command.build(trg)
  log.dbg "Building:", trg.repr
  log.dbg "Command :", cmd.repr


func run *(trg :BuildTarget) :BuildTarget {.discardable.}=
  log.dbg "Running:", trg.repr
  result = trg




# export namespace Build {
#
#
# export namespace Command {
#   export function C (
#     ) :string[] {
#     return [""]
#   } //:: confy.Build.Command.C
# } //:: confy.Build.Command
#
#
# } //:: confy.Build

