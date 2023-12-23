# confy dependencies
include confy/nims

# Package
packageName   = "hello"
version       = "0.0.0"
author        = "sOkam"
description   = "Confy: Hello Nim Build"
license       = "CC0-1.0"

# Dependencies
requires "nim >= 1.9.3"
# Should be active in a real project
# requires "https://github.com/heysokam/confy"

# Folders
system.srcDir = "src"

# Build task
task confy, "Builds the current nim project using confy.": confy()

