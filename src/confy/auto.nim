#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
when not defined(nimscript):
  import std/paths
# confy dependencies
import ./types

converter toBool    *(opt  :Opt)    :bool=    opt.bool
converter toPath    *(str  :string) :Path=    str.Path
converter toString  *(path :Path|Fil|Dir) :string=  path.string
converter toPathSeq *(list :seq[string])  :seq[Path]=
  for file in list:  result.add file.Path

