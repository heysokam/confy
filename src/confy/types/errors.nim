#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
## @fileoverview Error Types
#_____________________________|
type BuildError    * = object of CatchableError
type SomeToolError * = BuildError
