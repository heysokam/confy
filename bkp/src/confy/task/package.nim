#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/osproc
import std/strutils
import std/strformat
# confy dependencies
import ../cfg
import ../tool/logger
import ./base

#___________________
func getContent(line,pattern :string) :string {.inline.}=  line.replace( pattern & ": \"", "").replace("\"", "")
proc getInfo *() :Package=
  when debug: info &"Getting package information from {cfg.rootDir}"
  let data :seq[string]= execProcess("nimble dump", workingDir=cfg.rootDir).splitLines()
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

