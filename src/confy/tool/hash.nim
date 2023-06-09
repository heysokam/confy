#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import checksums/md5
# confy dependencies
import ../types
import ../auto


proc hash *(trg :Fil) :string=
  ## Returns the hash string of the given `trg` file contents, or empty if the file is not found.
  try:    result = trg.readFile.toMD5.`$`
  except: result = ""

