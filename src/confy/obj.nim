#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
# confy dependencies
import ./types
import ./state


proc new *(_ :typedesc[BuildObj];
    src :openArray[string]
  ) :BuildObj=  BuildObj(src: src)
  ## Creates a new BuildObj with the given data.

proc setup *(obj :BuildObj) :void=  discard
  ## Setup the object data to be ready for compilation.
proc clone *(obj :BuildObj) :BuildObj=  result = obj
  ## Returns a copy of the object, so it can be duplicated.
proc print *(obj :BuildObj) :void=  echo obj
  ## Prints all contents of the object to the command line.

