#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
## @fileoverview Base Types
#____________________________|
type URL        * = string
type PathLike   * = string
type SourceFile * = base.PathLike
type SourceList * = seq[base.SourceFile]
const NullPath  *:PathLike= "__Invalid_NULL_Path__"

