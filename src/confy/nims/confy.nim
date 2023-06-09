#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
import ./guard
# confy dpendencies, specifically for nims
import ../cfg         ; export cfg
import ../tool/logger ; export logger


#_________________________________________________________________________
# NOTE:                                                                   |
# Imported here because                                                   |
#   `../nimble.nim` is meant to be `include`d, not `import`ed             |
# This file will be imported from that file globally,                     |
# with a `nil` qualifier to solve for nimble nameclashes                  |
#                                                                         |
# This cable management makes the backend structure a bit more involved,  |
# but it keeps the exposed api to one single include line instead.        |
#_________________________________________________________________________|

