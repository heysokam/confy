#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________

import ./tools/helper as tHelper ; export tHelper
import ./tools/git    as tGit    ; export tGit

when not defined(nimscript):
  import ./tools/hash as tHash   ; export tHash
  import ./tools/db   as tDB     ; export tDB

