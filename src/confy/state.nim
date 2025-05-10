#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
import ./types

var cfg  *:types.Config=  types.Config()
  # @note Auto-passing this global config object to BuildTarget generation
  #       removes the option for them to be comptime defined :(

