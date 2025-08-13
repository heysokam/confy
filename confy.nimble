#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
when not defined(nimscript): import system/nimscript # Silence LSP errors

#_____________________________
# Package Information
packageName  = "confy"
version      = "0.8.14"
author       = "heysokam"
description  = "ᛝ confy | Comfortable and Configurable Buildsystem for C, C++, Zig and Nim"
license      = "GPLv3-or-later"
srcDir       = "src"
skipDirs     = @["caller", "src/caller"]

#_____________________________
# Build Requirements
requires "nim >= 2.0.0"
requires "https://github.com/heysokam/nstd#head"

