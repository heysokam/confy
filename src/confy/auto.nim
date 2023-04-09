#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths
# confy dependencies
import ./types

converter toBool    *(opt  :Opt)    :bool=    opt.bool
converter toString  *(path :Path)   :string=  path.string
converter toPath    *(str  :string) :Path=    str.Path
converter toPathSeq *(list :seq[string]) :seq[Path]=
  for file in list:  result.add file.Path

