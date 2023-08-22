#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your project.nims file.                         |
# Import dependencies are solved globally.             |
#_______________________________________________________
include ./nims/guard

# nims confy task
include ./nims/task
# confy dependencies for nims
from    ./nims/confy as c import nil

--nimcache:c.cacheDir
