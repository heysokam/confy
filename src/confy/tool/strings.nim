#:____________________________________________________
#  nstd  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:____________________________________________________
# Duplicate of nstd/strings to not depend on it  |
#________________________________________________|


#_______________________________________________
# strutils wrapper without empty string f*kery  |
#_______________________________________________|
import std/strutils as utils except contains ; export utils
from   std/strutils as std   import nil
#_______________________________________
proc contains *(A,B :string) :bool=
  # The reason for this file to exist:
  # assert A != "" and B != "", "Comparing two empty strings with `contains` is undecidable"
  if   B == "" and A != "" : return false  # "" in "something" == true   is just plain wrong
  elif A == "" and B == "" : return false  # undecidable. commit to false because nothing cannot contain anything
  elif B == A              : return true
  else: std.contains(A,B)
  # note:
  #   Strings in nim are considered sets, and the empty set triggers a Vacuous_truth in std.contains
  #   https://en.wikipedia.org/wiki/Vacuous_truth
  #   https://en.wikipedia.org/wiki/Syntactic_ambiguity
#_______________________________________________|
