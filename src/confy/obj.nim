#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
# confy dependencies
import ./types
import ./cfg as c


proc new *(_ :typedesc[BuildTrg];
    src  :seq[Path];
    trg  :Path= Path("");
    kind :BinKind= Program;
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg(kind: kind, src: src, trg: trg)

proc new *(kind :BinKind;
    src :seq[Path];
    trg :Path= Path("");
  ) :BuildTrg=
  ## Creates a new BuildTrg with the given data.
  BuildTrg.new(src, trg, kind)

proc setup *(obj :BuildTrg) :void=  discard
  ## Setup the object data to be ready for compilation.
proc clone *(obj :BuildTrg) :BuildTrg=  result = obj
  ## Returns a copy of the object, so it can be duplicated.
proc print *(obj :BuildTrg) :void=  echo obj
  ## Prints all contents of the object to the command line.

