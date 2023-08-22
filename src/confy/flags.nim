#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# confy dependecies
import ./types


#_______________________________________
# Helpers
#___________________
proc `&` *(f1,f2 :Flags) :Flags=  result.cc = f1.cc & f2.cc; result.ld = f1.ld & f2.ld
  ## Merges the flags of f1 and f2 into the result.
proc add *(trg :var Flags; src :Flags) :void=  trg = trg & src
  ## Adds the given `trg` flags into `src`.
proc join *(flags :varargs[Flags]) :Flags=
  ## Merges all flags of the given inputs into the result.
  for it in flags: result.add it
proc toCC *(flags :varargs[string]) :Flags=
  ## Converts the given list of strings into a cc flags object.
  for flag in flags: result.cc.add flag
proc toLD *(flags :varargs[string]) :Flags=
  ## Converts the given list of strings into a ld flags object.
  for flag in flags: result.ld.add flag


#_______________________________________
# Base Flag-sets
#___________________
const stdc  * = "-std=c11".toCC
const stdpp * = "-std=c++20".toCC
const less  * = Flags(
  cc: @[
  "-Wall",
  "-Wpedantic", "-pedantic",  # Enforce ISO C standard
  ])
const noerr * = Flags(
  cc: @[
  "-Wextra",
  "-Wdouble-promotion",  # Warn when a float is promoted to double
  "-m64",
  ])
const extra * = Flags(
  cc: @[
  # Recommended:
  "-Wmissing-prototypes","-Wmisleading-indentation","-Wold-style-definition",
  "-Wconversion","-Wshadow","-Winit-self","-Wfloat-equal",
  ])
const extraGCC * = Flags(  ## Extras only for pure C
 cc: @[
 "-Wstrict-prototypes","-Wduplicated-cond","-fdiagnostics-minimum-margin-width=5",
 "-Wcast-align=strict","-Wformat-overflow=2","-Wformat-truncation=2",
 "-fdiagnostics-format=text",#"-Wwrite-strings",
 ])
const extraPP * = Flags(
  cc: @["-Wcast-align",])
const error * = Flags(
  cc: @["-Werror", "-pedantic-errors",])

#___________________
const base  * = join( less, noerr )
const all   * = join( base, extra, error )
const allC  * = join( stdc, all )
const allPP * = join( stdpp, all, extraPP )
#___________________

