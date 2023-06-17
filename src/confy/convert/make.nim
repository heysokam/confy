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
proc make *(dir :string; trgs :varargs[string, `$`]) :string=
  var cmd :string= &"cd {dir}; make"
  for arg in trgs: cmd.add " "&arg
  if not dir.dirExists: echo "Tried to access folder ",dir,", but it does not exist."; gerr ""
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


#_______________________________________
proc getTargets *(
    rootDir : Dir    = Dir(".");
    keyword : string = "";
    prefix  : string = "auto";
    force   : bool   = false;
  ) :seq[BuildTrg]=
  var parsed = rootDir.make(keyword).toLines.parse
  result = parsed.toTargets


#_______________________________________
proc writeCode *(
    file    : Fil;
    dir     : Dir;
    root    : Dir    = "";
    keyword : string = "";
    prefix  : string = "auto";
    dbg     : bool   = off;
  ) :void=
  ## Generates the buildcode from `dir` and the given `keyword`,
  ## and writes it to `file` using the given prefix in the names of all entries.
  ## Corrects the code to be relative to `root` when not omitted.
  let dirFile  = dir/"dir.nim"   # Folders to glob
  let srcFile  = dir/"src.nim"   # Globbed files
  let diffFile = dir/"diff.nim"  # Filters to remove and add
  let rawFile  = dir/"make.sh"   # Raw list of commands
  if not dir.dirExists: dir.createDir
  # Parse the input file
  let trgs = root.getTargets(keyword, prefix, force = true)
  if trgs.len > 1: trgs.toFile(file, prefix)
  else:            trgs[0].toFile(file, prefix)
  let srcs     = trgs.getSources( root=root, dbg=dbg)
  let globCode = srcs.globs.toString( root=root )
  let diffCode = srcs.diffs.toString(srcs.trees, root=root )
  dir.createDir
  dirFile.writeFile( globCode.dir )
  srcFile.writeFile( globCode.src )
  diffFile.writeFile( diffCode )
  rawFile.writeFile( root.make(keyword) )
#_____________________________
proc writeAll *(dir :Dir; dest :Dir; name :string) :void=
  ## Generates the buildcode for all targets and platforms from dir,
  ## and writes it to the dest folder, using name as the key for the files/folders.
  let outDir = dest/name
  let lnxDir = outDir/"lnx"
  let winDir = outDir/"win"
  let macDir = outDir/"mac_x64"
  let armDir = outDir/"mac_aarch64"
  writeCode(lnxDir/name&".nim",
    dir     = lnxDir,
    root    = dir,
    keyword = "all PLATFORM=linux", # mac
    prefix  = name,
    dbg     = off,
    ) # << writeCode( ... )
  writeCode(winDir/name&".nim",
    dir     = winDir,
    root    = dir,
    keyword = "all PLATFORM=mingw64", # windows with mingw
    prefix  = name,
    dbg     = off,
    ) # << writeCode( ... )
  writeCode(macDir/name&".nim",
    dir     = macDir,
    root    = dir,
    keyword = "CC=/usr/local/osx-ndk-x86/bin/osxcross MACOSX_VERSION_MIN=10.9 all PLATFORM=darwin ARCH=x86_64", # mac x86_64
    prefix  = name,
    dbg     = off,
    ) # << writeCode( ... )
  writeCode(armDir/name&".nim",
    dir     = armDir,
    root    = dir,
    keyword = "CC=/usr/local/osx-ndk-x86/bin/osxcross MACOSX_VERSION_MIN=10.9 all PLATFORM=darwin ARCH=aarch64", # mac aarch64
    prefix  = name,
    dbg     = off,
    ) # << writeCode( ... )

