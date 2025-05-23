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
  # Remove purely stylistic warnings
  "-Wno-declaration-after-statement",
  "-Wno-covered-switch-default",
  # Warn of dodgy situations
  "-Wno-error=vla",
  "-Wno-error=padded",
  "-Wno-error=pre-c2x-compat",
  "-Wno-error=unsafe-buffer-usage",
  "-Wno-error=#warnings",
  "-Wno-error=documentation",
  "-Wno-error=documentation-unknown-command",
  # Silence Errors for perfectly valid modern code
  "-Wno-c++98-c++11-c++14-c++17-compat", "-Wno-c++98-c++11-c++14-c++17-compat-pedantic",  "-Wno-c++98-c++11-c++14-compat",    "-Wno-c++98-c++11-c++14-compat-pedantic",
  "-Wno-c++98-c++11-compat",             "-Wno-c++98-c++11-compat-binary-literal",        "-Wno-c++98-c++11-compat-pedantic",
  "-Wno-c++98-compat",                   "-Wno-c++98-compat-bind-to-temporary-copy",      "-Wno-c++98-compat-extra-semi",     "-Wno-c++98-compat-local-type-template-args",      "-Wno-c++98-compat-pedantic", "-Wno-c++98-compat-unnamed-type-template-args",
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

