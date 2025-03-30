#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
## @fileoverview Error Types
#_____________________________|
type CompileError * = object of IOError
  ## @descr For exceptions during the compile process
type GeneratorError * = object of IOError
  ## @descr For exceptions during code generation.
type SomeToolError * = CompileError | GeneratorError
