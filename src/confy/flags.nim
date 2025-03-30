#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps confy

const C * = @[
  "-std=c2x",
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
  ] #:: flags.C

const Cpp * = flags.C  # FIX: C++ specific

