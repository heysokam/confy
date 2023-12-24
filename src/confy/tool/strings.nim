#:____________________________________________________
#  nstd  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
## @fileoverview
##  Duplicate of nstd/strings to not depend on it.
##  strutils wrapper without empty string f*kery.
##  @reason for this file to exist:
##   assert A != "" and B != "", "Comparing two empty strings with `contains` is undecidable"
##   @see {@link:here contains}
#______________________________________________________________|
# @deps std
import std/strutils as utils except contains ; export utils except contains
from   std/strutils as std import nil

#_______________________________________
proc contains *(A,B :string) :bool=
  ## @descr Returns whether or not the string {@link:arg B} is contained in {@link:arg A}
  ## @important Read the {@link:here fileoverview} for an explanation.
  ## @why
  ##  Strings in nim are considered sets, and the empty set triggers a Vacuous_truth in std.contains
  ##  @see https://en.wikipedia.org/wiki/Vacuous_truth
  ##  @see https://en.wikipedia.org/wiki/Syntactic_ambiguity
  if   B == "" and A != "" : return false  # "" in "something" == true   is just plain wrong
  elif A == "" and B == "" : return false  # undecidable. commit to false because nothing cannot contain anything
  elif B == A              : return true
  else: std.contains(A,B)

#_______________________________________
# Extensions
#___________________
# Strings
proc startsWith *(entry :string; args :varargs[string, `$`]) :bool=
  ## @descr Checks if the given {@link:arg entry} string starts with any of the (varargs) {@link:arg args} list.
  for arg in args:
    if utils.startsWith(entry, arg): return true

