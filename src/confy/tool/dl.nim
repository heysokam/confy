#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/strformat
# @deps external
import pkg/puppy
# @deps ndk
import nstd/paths
# @deps confy
import ./logger
import ../cfg

proc file *(url :string; trgFile :Path; report :bool= true) :void=
  if report: log &"Downloading {url}\n{tab}as {trgFile}..."
  trgFile.writeFile( puppy.get(url).body )

