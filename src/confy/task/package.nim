#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/osproc
from std/strformat import `&`
# @deps confy
import ../types
import ../cfg
import ../tool/strings
import ../tool/paths
import ../builder/nim
# @deps confy.task
# import ./base
when debug:
  import std/strformat
  import ../tool/logger

#___________________
func getContent(line,pattern :string) :string {.inline.}=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getInfo *() :Package=
  when debug: logger.info &"Getting package information from {cfg.rootDir}"
  let data :seq[string]= osproc.execProcess(&"{nim.getRealNimble()} dump", workingDir=cfg.rootDir.string).splitLines()
  for line in data:
    if   line.startsWith("name:")    : result.name        = line.getContent("name")
    elif line.startsWith("version:") : result.version     = line.getContent("version")
    elif line.startsWith("author:")  : result.author      = line.getContent("author")
    elif line.startsWith("desc:")    : result.description = line.getContent("desc")
    elif line.startsWith("license:") : result.license     = line.getContent("license")
    #ignored: skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, requires, bin, binDir, srcDir, backend
  when debug:
    if result.name == ""        : info2 "Package name wasn't found in .nimble"
    if result.version == ""     : info2 "Package version wasn't found in .nimble"
    if result.author == ""      : info2 "Package author wasn't found in .nimble"
    if result.description == "" : info2 "Package description wasn't found in .nimble"
    if result.license == ""     : info2 "Package license wasn't found in .nimble"

