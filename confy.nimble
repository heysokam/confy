#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# confy dependencies
include confy/nimble

#_____________________________
# Package
packageName   = "confy"
version       = "0.0.0"
author        = "sOkam"
description   = "confy buildsystem"
license       = "MIT"

#_____________________________
# Dependencies
requires "nim >= 1.6.12"

#_____________________________
# Folders
srcDir       = c.srcDir
binDir       = c.binDir
let helloDir = c.examplesDir/"hello"

#_____________________________________________________
task demo, "Executes confy inside the demo folder":
  withDir helloDir: exec c.nimble&" confy"

