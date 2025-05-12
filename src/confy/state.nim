#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
import ./types
import ./tools/args


var cli  *:args.CLI=  args.getCLI()  ## @descr
  ##  Global State of CLI arguments passed to the builder

var cfg  *:types.Config=  types.Config()  ## @descr
  ##  Global State of the builder Config options
  # @note Auto-passing this global config object to BuildTarget generation
  #       removes the ability for them to be comptime defined :(

