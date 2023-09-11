exec "nimble install https://github.com/heysokam/confy@#head"

# Package
packageName   = "hello"
version       = "0.0.0"
author        = "sOkam"
description   = "Confy: Full Nim Build"
license       = "CC0-1.0"

# include confy/nims  # This version should be active in a real project, and the relative path line removed
include ../../src/confy/nims
confy()
