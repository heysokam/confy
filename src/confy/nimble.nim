#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# WARNING:                                             |
# This file is meant to be `include`d, not `import`ed, |
# into your project.nimble file.                       |
# Import dependencies are solved globally.             |
#_______________________________________________________

# nimble confy task
include confy/nimble/task
# confy dependencies for nimble
import  confy/nimble/deps
from    confy/nimble/confy as c import nil

--nimcache:c.cacheDir
