#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Base internal funcionality for all builder modules  |
#_____________________________________________________|
# std dependencies
import std/paths
import std/dirs
import std/strformat
import std/strutils
# confy dependencies
import ../types
import ../tool/logger
import ../tool/helper
import ../cfg as c
import ../dirs
import ../flags as fl


#_____________________________
const ext = Extensions(
  unix: Extension(os: OS.Linux,   bin: "",     lib: ".so",    obj: ".o"),
  win:  Extension(os: OS.Windows, bin: ".exe", lib: ".dll",   obj: ".obj"),
  mac:  Extension(os: OS.Mac,     bin: ".app", lib: ".dylib", obj: ".o"),
  )
proc isLib *(file :Fil) :bool=  file.splitFile.ext in [ext.unix.lib, ext.win.lib, ext.mac.lib]
#_____________________________
const validExt = [".cpp", ".cc", ".c", ext.unix.obj, ext.win.obj, ext.mac.obj]
proc isValid (src :string) :bool=  src.splitFile.ext in validExt
  ## Returns true if the given src file has a valid known file extension.
#_____________________________
proc toLib (file :Fil; os :OS) :Fil=
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.lib
  of   OS.Windows:  file.changeFileExt ext.win.lib
  of   OS.Mac:      file.changeFileExt ext.mac.lib
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc toObj (file :Fil; os :OS) :Fil=
  case os
  of   OS.Linux:    file.changeFileExt ext.unix.obj
  of   OS.Windows:  file.changeFileExt ext.win.obj
  of   OS.Mac:      file.changeFileExt ext.mac.obj
  else: raise newException(CompileError, &"Support for {os} is currently not implemented.")
#_____________________________
proc isObj (trg :Fil) :bool=  trg.splitFile.ext in [ext.unix.obj, ext.win.obj, ext.mac.obj]
  ## Returns true if the `trg` file is already a compiled object.
#_____________________________
proc isBin *(file :Fil) :bool= 
  ## Returns true if the target `file` is considered to have a known binary file extension.
  if file.isValid: return false  # Never set binary flags for valid compilation unit extensions .o .a .c .cc .cpp
  case file.splitFile.ext
  of ext.unix.bin, ext.win.bin, ext.mac.bin:  return true   # Known binary extensions
  of ext.unix.lib, ext.win.lib, ext.mac.lib:  return false  # dynamic libs are not binaries
  of ext.unix.obj, ext.win.obj:               return false  # objects are not binaries
  else: return true  # Custom extensions (perfectly valid for linux) will be considered binaries.
  # wrn: File extensions for unknown os'es will always return true. Add the os to the `ext` list if this is an issue.



#_____________________________
# Direct compilation
#___________________
proc direct * (
    src      : Fil;
    trg      : Fil;
    CC       : string;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## Builds the `src` file directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step, unless the CC command includes the "-c" option.
  let flg   = flags.join(" ")
  let cmd   = &"{CC} {flg} {src} -o {trg}"
  if quiet: echo &"{quietStr} {trg}"
  else:     echo cmd
  sh cmd
  if trg.isBin: trg.setExec()  # Set executable flags on the resulting binary.
#___________________
proc direct * (
    src      : seq[Fil];
    trg      : Fil;
    CC       : string;
    flags    : seq[string];
    quietStr : string;
  ) :void=
  ## Builds the `src` list of files directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  let files = src.join(" ")
  let flg   = flags.join(" ")
  let cmd   = &"{CC} {files} {flg} -o {trg}"
  if not quiet: echo &"{quietStr} {trg}"
  elif verbose: echo cmd
  else:         log &"Linking {trg} ..."
  sh cmd
  if trg.isBin: trg.setExec()  # Set executable flags on the resulting binary.


#_____________________________
# GCC: Linker
#___________________
proc link *(
    src   : seq[Fil];
    trg   : Fil;
    CC    : string;
    flags : Flags;
  ) :void=
  ## Links the given `src` list of files into the `trg` binary.
  direct(src, trg, CC, flags.ld, Lstr)

#_____________________________
# GCC: Compiler
#___________________
proc compileNoObj *(
    src      : seq[Fil];
    trg      : Fil;
    CC       : string;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files using the given CC into the `trg` binary.
  ## Doesn't compile an intermediate `.o` step.
  direct(src, trg, CC, flags.cc, quietStr)
#___________________
proc compileToObj *(
    src      : seq[Fil];
    dir      : Dir;
    CC       : string;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  for file in src:
    let trg = file.chgDir(file.splitFile.dir, dir).changeFileExt(".o")
    file.direct(trg, CC&" -c", flags.cc, quietStr)
#___________________
proc compileToMod *(
    src      : seq[Fil];
    dir      : Dir;
    CC       : string;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files as named modules, and outputs them into the `dir` folder.
  for file in src:
    let trg = file.chgDir(file.splitFile.dir, dir).changeFileExt(".pcm")
    file.direct(trg, CC&" -c", flags.cc, quietStr)

#___________________
proc compile *(
    src      : seq[Fil];
    trg      : Fil;
    CC       : string;
    flags    : Flags;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files using `gcc`
  ## Assumes the paths given are already relative/absolute in the correct way.
  var objs :seq[Fil]
  var cmds :seq[string]
  var cfl  = flags.cc.join(" ")
  log &"Building {trg} ..."
  if quiet: stdmsg.write &"{tab}|" # add | to start the line of the silent case
  for file in src:
    var trg  = file.chgDir(srcDir, binDir)
    if trg.isObj:  # File is already an object. Add to objs and continue
      objs.add(trg); continue
    trg = trg.toObj(OS.Linux)
    let dir = trg.splitFile.dir
    let cmd = &"{CC} -MMD {cfl} -c {file} -o {trg}"
    if   quiet:   stdmsg.write "."
    elif verbose: echo cmd
    else:         echo &"{Cstr} {trg}"
    objs.add trg
    if not dir.dirExists: createDir dir
    sh cmd
    # cmds.add cmd
  if quiet: echo "Done." # add \n to end the line of the silent case
  # sh cmds, c.cores
  objs.link(trg, CC, flags)
#___________________
proc compileShared *(
    src      : seq[Fil];
    trg      : Fil;
    CC       : string;
    flags    : Flags;
    syst     : System;
    quietStr : string;
  ) :void=
  ## Compiles the given `src` list of files as a SharedLibrary, using `gcc`.
  ## Assumes the paths given are already relative/absolute in the correct way.
  src.compile(trg.toLib(syst.os), CC, Flags(cc: flags.cc, ld: flags.ld & "-shared"), quietStr)

#___________________
proc compile *(
    src      : seq[Fil];
    obj      : BuildTrg;
    CC       : string;
    flags    : Flags;
    quietStr : string;
  ) :void=
  case obj.kind
  of Program:        src.compile(obj.trg, CC, obj.flags, quietStr)
  of Object:         src.compileToObj(obj.root, CC, obj.flags, quietStr)
  of Module:         src.compileToMod(obj.root, CC, obj.flags, quietStr)
  of SharedLibrary:  src.compileShared(obj.trg, CC, obj.flags, obj.syst, quietStr)
  of StaticLibrary:  cerr "Compiling as StaticLibrary is not implemented."

