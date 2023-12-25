# Package
packageName   = "hello"
version       = "0.0.0"
author        = "sOkam"
description   = "Confy: Full Nim Build"
license       = "CC0-1.0"
# Dependencies
requires "nim >= 2.0.0"
# Folders
srcDir        = "src"
task confy, "Builds the current nim project using confy.":
  requires "https://github.com/heysokam/confy#head"
  exec "nim confy.nims"
