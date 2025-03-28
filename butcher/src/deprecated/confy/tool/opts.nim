#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Duplicate of nstd/opts to not depend on it  |
#_____________________________________________|
# std dependencies
import std/os
import std/parseopt


#_____________________________
# CLI options
type ArgList * = seq[string]
type OptList * = object
  short *:seq[string]
  long  *:seq[string]
#_____________________________
type CLI * = object
  args  *:ArgList
  opts  *:OptList

#_________________________________________________
# General CLI parse
#_____________________________
proc getCLI *() :CLI=
  var parser = commandLineParams().initOptParser()
  for kind, key, val in parser.getOpt():
    case kind
    of cmdArgument:    result.args.add( key )
    of cmdLongOption:  result.opts.long.add( key )
    of cmdShortOption: result.opts.short.add( key )
    of cmdEnd:         assert true

#_________________________________________________
# Get specific Elements
#_____________________________
proc getArgs *() :seq[string]=  getCLI().args
proc getArg  *(id :SomeInteger) :string=  getCLI().args[id]
proc getOpt  *(opt :char|string) :bool=
  ## Returns true if the given short option was passed in CLI
  let cli   = getCLI()
  let short = cli.opts.short()
  let long  = cli.opts.long()
  # Treat the input as a short option
  when opt is char:
    return $opt in short
  elif opt is string:
    # Treat the input as a long option
    if opt.startsWith("--"):
      return $opt[2..^1] in long
    # Treat the input as a list of options in a single word, or as a short option starting with `-`
    else:
      var list :string= opt
      if list.startsWith("-"): list = list[1..^1]  # Remove the first character from the input
      for ch in list:
        if ch notin short: return false  # Exit early when one of the characters of the `opt` input was not passed in cli
      return true                        # All options of the `opt` input were passed in cli, so return true

