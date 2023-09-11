# Package
packageName   = "hello"
version       = "0.0.0"
author        = "sOkam"
description   = "Confy: Full Nim Build"
license       = "CC0-1.0"
# Dependencies
requires "nim >= 2.0.0"
# Should be active in a real project
# requires "https://github.com/heysokam/confy"
# Folders
srcDir        = "src"
task confy, "Builds the current nim project using confy.": exec "nim confy.nims"
