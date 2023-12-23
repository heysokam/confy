# confy dependencies
include confy/nims

#_____________________________
# Package
var packageName   = "hello"
var version       = "0.0.0"
var author        = "sOkam"
var description   = "Hello Confy"
var license       = "CC0-1.0"

#_____________________________
# Dependencies
# requires "nim >= 1.9.3"
# requires "https://github.com/heysokam/confy"

#_____________________________
# Folders
system.srcDir = c.srcDir
system.binDir = c.binDir

#_____________________________
# Run Builder
confy()
