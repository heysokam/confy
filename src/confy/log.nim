#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/strutils import join

func dbg *(msg :varargs[string, `$`]) :void= debugEcho(msg.join(" "))

