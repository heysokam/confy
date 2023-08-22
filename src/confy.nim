#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________

import ./confy/types       ; export types
import ./confy/cfg         ; export cfg
import ./confy/tools       ; export tools
import ./confy/builder     ; export builder
import ./confy/dirs        ; export dirs
import ./confy/obj as cObj ; export cObj
import ./confy/flags       ; export flags

## WARNING:
## This seamlessly converts from string to Path without the compiler saying anything about it.
##   Important for nimble and nimscript integration and usability
##   because of not having to do explictic convertion in the project's src/confy.nim file
import ./confy/auto  as cAuto  ; export cAuto

