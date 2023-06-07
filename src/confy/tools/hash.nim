#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import checksums/md5
# confy dependencies
import ../types
import ../auto


proc hash *(trg :Fil) :string=  trg.readFile.toMD5.`$`
  ## Returns the hash string of the given `trg` file contents.

