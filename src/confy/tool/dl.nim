#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/strformat
# @deps external
import puppy
# @deps confy
import ./logger
import ../cfg

proc file *(url, trgFile :string; report :bool= true) :void=
  if report: log &"Downloading {url}\n{tab}as {trgFile}..."
  trgFile.writeFile( puppy.get(url).body )

