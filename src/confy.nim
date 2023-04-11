#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________

import ./confy/types   as cTypes   ; export cTypes
import ./confy/state   as cState   ; export cState
import ./confy/tools   as cTools   ; export cTools
import ./confy/obj     as cObj     ; export cObj
import ./confy/builder as cBuilder ; export cBuilder
import ./confy/dirs    as cDirs    ; export cDirs

## WARNING:
## This seamlessly converts from string to Path without the compiler saying anything about it.
##   Important for nimble and nimscript integration and usability
##   because of not having to do explictic convertion in the project's src/confy.nim file
import ./confy/auto  as cAuto  ; export cAuto

