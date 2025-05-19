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
from ./confy/flags         import nil ; export flags
from ./confy/tools/version import nil ; export version
from ./confy/tools/git     import nil ; export git
from ./confy/tools/files   import nil ; export files
from ./confy/tools/args    import nil ; export args
from ./confy/tools/shell   import nil ; export shell
from ./confy/log           import nil ; export log
from ./confy/command       import nil ; export command
from ./confy/systm as sys  import nil ; export sys
from ./confy/types import nil
from ./confy/types/base import Name
export Name
export types.Config
export types.System
export types.OS ; export types.CPU ; export types.ABI
export types.build.Mode; export types.build.ModeKind; export types.build.ModeOptim
from ./confy/state as G import nil ;
export G.cfg ; export G.cli

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

