#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps ndk
import nstd/paths
# @deps confy
import ../tools
import ../types
import ./zigcc


#_____________________________
# Assembler: Compiler
#___________________
proc compile *(
  src   : PathList;
  obj   : BuildTrg;
  force : bool= false;
  ) :void=
  if obj.kind != Object: cerr "Compiling Assembly into non-Object files is not supported."
  zigcc.compile(src, obj, force)

