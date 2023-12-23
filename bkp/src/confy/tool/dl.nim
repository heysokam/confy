#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# External dependencies
import std/strformat
import std/httpclient
# confy dependencies
import ./logger
import ../cfg

proc file *(url, trgFile :string; report :bool= true) :void=
  let client = newHttpClient()
  if report: log &"Downloading {url}\n{tab}as {trgFile}..."
  client.downloadFile(url, trgFile)

