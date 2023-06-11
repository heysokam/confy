#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Make-to-Confy Converter tool.                   |
# CLI parsing and codegen from `make keyword -n`  |
#_________________________________________________|
# std dependencies
import std/os except `/`
import std/osproc
import std/paths
import std/strformat
# confy dependencies
import ../types
import ../tool/logger
import ./make/parse
import ./make/codegen as gen


#___________________
proc make (dir :string; trgs :varargs[string, `$`]) :string=
  var cmd :string= &"cd {dir}; make"
  for arg in trgs: cmd.add " "&arg
  if not dir.dirExists: gerr "Tried to access folder ",dir,", but it does not exist."
  log "Executing ...\n  "&cmd
  result = execProcess(cmd & " -n")

#___________________
proc toConfy *(
    rootDir : Dir    = Dir(".");
    trgFile : Fil    = Fil("");
    keyword : string = "";
    prefix  : string = "auto";
    force   : bool   = false;
  ) :void=
  ## Converts the output of `make keyword -n` into a confy file.
  ## Defaults when omitted:
  ##   rootDir : Make is run from the current folder
  ##   trgFile : The output of the conversion is generated into `rootDir`/build.nim
  ##   keyword : Keyword will be "" when omitted.
  ##   force   : The operation will fail if a file with that name already exists, unless `force` is set to active.
  let trg :Fil= if trgFile == Fil(""): rootDir/"build.nim" else: trgFile
  if trg.fileExists and not force: gerr "Tried to generate the file {trg} from {rootDir}, but the file already exists."
  log &"Generating code for {trg.string} from the pretend command `make {keyword} -n` run inside {rootDir} ..."
  var parsed = rootDir.make(keyword).toLines.parse
  let trgs   = parsed.toTargets
  if trgs.len > 1: trgs.toFile(trg, prefix)
  else:            trgs[0].toFile(trg, prefix)
  log &"Codegen for {trg.string} done."

