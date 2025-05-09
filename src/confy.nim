#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
##! @fileoverview
##!
##!  Confy : Comfortable and Configurable Buildsystem
##!  @todo : Docs here
#_____________________________________________________|
from ./confy/target        import nil ; export target
from ./confy/package       import nil ; export package
from ./confy/dependency    import nil ; export dependency
from ./confy/tools/version import nil ; export version
from ./confy/log           import nil ; export log
from ./confy/types import nil
export types.Config
var cfg *:types.Config= types.Config()

#_______________________________________
# @section Forward Export useful nstd tools
#_____________________________
from nstd/shell as nstd_shell import nil
export nstd_shell.withDir
export nstd_shell.sh
export nstd_shell.ln
export nstd_shell.cp

#_______________________________________
# @section Forward Export useful std tools
#_____________________________
from std/os import nil
export os.`/`
export os.fileExists
export os.dirExists
export os.getEnv
export os.parentDir
export os.removeDir

