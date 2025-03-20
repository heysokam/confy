#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps confy
import ../tools
import ../types
import ./zigcc


#_____________________________
# Assembler: Compiler
#___________________
proc compile *(
  src   : seq[DirFile];
  obj   : BuildTrg;
  force : bool= false;
  ) :void=
  if obj.kind != Object: cerr "Compiling Assembly into non-Object files is not supported."
  zigcc.compile(src, obj, force)

