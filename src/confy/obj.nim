#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
# confy dependencies
import ./types
import ./state


proc new *(_ :typedesc[BuildObj];
    src  :seq[Path];
    trg  :Path= Path("");
    kind :BinKind= Program;
  ) :BuildObj=
  ## Creates a new BuildObj with the given data.
  BuildObj(kind: kind, src: src, trg: trg)

proc new *(kind :BinKind;
    src :seq[Path];
    trg :Path= Path("");
  ) :BuildObj=
  ## Creates a new BuildObj with the given data.
  BuildObj.new(src, trg, kind)

proc setup *(obj :BuildObj) :void=  discard
  ## Setup the object data to be ready for compilation.
proc clone *(obj :BuildObj) :BuildObj=  result = obj
  ## Returns a copy of the object, so it can be duplicated.
proc print *(obj :BuildObj) :void=  echo obj
  ## Prints all contents of the object to the command line.

