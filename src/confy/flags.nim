#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# TODO: Port Complete list of flags from butcher
#________________________________________________|
# @deps confy
import ./types/build

#_______________________________________
# @section Forward Export Flags Types
#_____________________________
export build.Flag
export build.Flags


#_______________________________________
# @section Default Flags Lists
#_____________________________
const Strict * = @[
  "-Weverything",
  "-Werror",
  "-pedantic",
  "-pedantic-errors",
  "-Wno-declaration-after-statement",
  "-Wno-error=vla",
  "-Wno-error=padded",
  "-Wno-error=pre-c2x-compat",
  "-Wno-error=unsafe-buffer-usage",
  "-Wno-error=#warnings",
  ]
#___________________
func std *(lang :build.Lang) :build.Flag=
  case lang
  of C   : "-std=c2x"
  of Cpp : "-std=c++20"
  else   : ""


#_______________________________________
# @section Default Flags (Strict)
#_____________________________
const C   * = @[Lang.C.std()]   & flags.Strict
const Cpp * = @[Lang.Cpp.std()] & flags.Strict

