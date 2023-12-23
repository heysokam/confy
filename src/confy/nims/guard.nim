#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview
##  Error when loading any files of this module from a non-nimscript source.
##  The nims section is completely isolated from confy.
#_____________________________________________________
from ../types import nims
when not nims:
  const nimsMsg :string= "Tried to add a nimscript-only module into a binary app."
  when defined(debug) : {.warning: nimsMsg.}
  else                : {.error: nimsMsg.}

