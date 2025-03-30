#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps confy
import ./types
import ./config
import ./lang
from   ./log import nil

type BuildError * = object of CatchableError
type Build *{.pure.}= enum None, Program, SharedLib, StaticLib, UnitTest, Object
type BuildTarget = object
  kind   *:Build
  src    *:SourceList
  cfg    *:Config
  lang   *:Lang


func new *(kind :Build;
    src :string;
  ) :BuildTarget=
  result.kind = kind
  result.src  = @[src]
  result.lang = Lang.identify(result.src)

func build *(trg :BuildTarget) :BuildTarget {.discardable.}=
  result = trg
  log.dbg "Building:", trg.repr

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

