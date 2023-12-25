# Package
packageName   = "cross"
version       = "0.0.0"
author        = "sOkam"
description   = "Confy: Cross-Compilation Nim Build"
license       = "CC0-1.0"

# Dependencies
requires "nim >= 2.0.0"

# Build task
task confy, "Builds the current nim project using confy.":
  requires "https://github.com/heysokam/confy#head"
  exec "nim confy.nims"
