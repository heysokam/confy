#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps zigcc
import ./zigcc/bin

#_____________________________
# Setup/Download
#___________________
proc initOrExists *(force=false) :bool=  bin.initOrExists(force=force)
  ## Initializes the zig compiler binary, or returns true if its already initialized.


