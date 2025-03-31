#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps confy
import ./types

#_______________________________________
# Helpers
#___________________
proc `&` *(f1,f2 :Flags) :Flags=  result.cc = f1.cc & f2.cc; result.ld = f1.ld & f2.ld
  ## @descr Merges the flags of f1 and f2 into the result.
proc add *(trg :var Flags; src :Flags) :void=  trg = trg & src
  ## @descr Adds the given `trg` flags into `src`.
proc join *(flags :varargs[Flags]) :Flags=
  ## @descr Merges all flags of the given inputs into the result.
  for it in flags: result.add it
proc toCC *(flags :varargs[string]) :Flags=
  ## @descr Converts the given list of strings into a cc flags object.
  for flag in flags: result.cc.add flag
proc toLD *(flags :varargs[string]) :Flags=
  ## @descr Converts the given list of strings into a ld flags object.
  for flag in flags: result.ld.add flag

#_______________________________________
# Compiler Flag sets
#___________________
const less * = Flags(
  cc: @[
  "-Wall",
  "-Wpedantic", "-pedantic",  # Enforce ISO C standard
  ])
#___________________
const noerr * = Flags(
  cc: @[
  "-Wextra",
  "-Wdouble-promotion",  # Warn when a float is promoted to double
  "-m64",
  ])
#___________________
const error * = Flags(
  cc: @["-Werror", "-pedantic-errors",])
#___________________
const extra * = Flags(
  cc: @[
  # Recommended:
  "-Wmissing-prototypes","-Wmisleading-indentation","-Wold-style-definition",
  "-Wconversion","-Wshadow","-Winit-self","-Wfloat-equal",
  ]) # << extra Flags( ... )
func extras *(lang :Lang= Lang.Unknown) :Flags=
  case lang
  of C: Flags(
    cc: @[
    "-Wstrict-prototypes","-Wduplicated-cond","-fdiagnostics-minimum-margin-width=5",
    "-Wcast-align=strict","-Wformat-overflow=2","-Wformat-truncation=2",
    "-fdiagnostics-format=text",#"-Wwrite-strings",
    ]) # C.extras Flags( ... )
  of Cpp: Flags(
    cc: @["-Wcast-align",
    ]) # Cpp.extras Flags( ... )
  of Unknown: flags.extra
  else: Flags()
#___________________
# Combined sets
const base = join( less, noerr )
func all *(lang :Lang= Lang.Unknown) :Flags=
  const defaults = join( base, extra, error )
  case lang
  of C       : join( C.std(), defaults )
  of Cpp     : join( Cpp.std(), defaults, Cpp.extras() )
  of Unknown : defaults
  else       : Flags()
