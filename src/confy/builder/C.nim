#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/paths
import std/dirs
import std/strformat
import std/strutils
# confy dependencies
import ../types
import ../tools
import ../cfg as c
import ../tool/logger
import ../dirs
import ../flags as fl
# Builder Module dependencies
import ./base


#_____________________________
let   gcc    = if c.verbose: "gcc -v" else: "gcc"
let   gccp   = if c.verbose: "g++ -v" else: "g++"
let   clang  = if c.verbose: "clang -v"   else: "clang"
let   clangp = if c.verbose: "clang++ -v" else: "clang++"
#_____________________________
proc exists *(c :Compiler) :bool=
  ## Returns true if the given compiler exists in the system.
  case c
  of GCC:   result = gorgeEx(gcc   & " --version").exitCode == 0
  of Clang: result = gorgeEx(clang & " --version").exitCode == 0
  else:     result = false
#_____________________________
const ext = Extensions(
  unix: Extension(os: OS.Linux,   bin: "",     lib: ".so",    obj: ".o"),
  win:  Extension(os: OS.Windows, bin: ".exe", lib: ".dll",   obj: ".obj"),
  mac:  Extension(os: OS.Mac,     bin: ".app", lib: ".dylib", obj: ".o"),
  )
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
const validExt = [".cpp", ".cc", ".c", ext.unix.obj, ext.win.obj, ext.mac.obj]
proc isValid (src :string) :bool=  src.splitFile.ext in validExt
  ## Returns true if the given src file has a valid known file extension.

#_____________________________
proc getCC (src :string) :string=
  ## Returns the correct gcc command to build the given src file.
  case src.splitFile.ext
  of ".cpp", ".cc", ext.unix.obj, ext.win.obj:
    result = gccp
  of ".c": result = gcc
  else:    result = "echo"
  echo src, "  ", src.splitFile.ext, "   ", result

# addFileExt proc

# >>  Remember to add executable flags to the resulting binaries


#_____________________________
# GCC: Internal
#___________________
proc direct (
    src      : Fil;
    trg      : Fil;
    flags    : seq[string];
    quietStr : string;
    ccmd     : string = gccp;
  ) :void=
  ## Builds the `src` file directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  let flg   = flags.join(" ")
  let cmd   = &"{ccmd} {flg} {src} -o {trg}"
  if quiet: echo &"{quietStr} {trg}"
  else:     echo cmd
  sh cmd

proc direct (
    src      : seq[Fil];
    trg      : Fil;
    flags    : seq[string];
    quietStr : string;
    ccmd     : string = gccp;
  ) :void=
  ## Builds the `src` list of files directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  let files = src.join(" ")
  let flg   = flags.join(" ")
  let cmd   = &"{ccmd} {files} {flg} -o {trg}"
  if quiet: echo &"{quietStr} {trg}"
  else:     echo cmd
  sh cmd

#_____________________________
# GCC: Linker
#___________________
proc link *(src :seq[Fil]; trg :Fil; flags :Flags= fl.allPP; ccmd :string= gccp) :void=
  ## Links the given `src` list of files into the `trg` binary.
  direct(src, trg, flags.ld, Lstr, ccmd)

#_____________________________
# GCC: Compiler
#___________________
proc compileNoObj *(src :seq[Fil]; trg :Fil; flags :Flags= fl.allPP) :void=  direct(src, trg, flags.cc, Cstr)
  ## Compiles the given `src` list of files using `gcc` into the `trg` binary.
  ## Doesn't compile an intermediate `.o` step.
proc compileToObj *(src :seq[Fil]; dir :Dir; flags :Flags= fl.allPP; quietStr :string= Cstr) :void=
  ## Compiles the given `src` list of files as objects, and outputs them into the `dir` folder.
  for file in src:
    let trg = file.chgDir(file.splitFile.dir, dir).changeFileExt(".o")
    file.direct(trg, flags.cc, quietStr, file.getCC()&" -c")
proc compileToMod *(src :seq[Fil]; dir :Dir; flags :Flags= fl.allPP; quietStr :string= Cstr) :void=
  ## Compiles the given `src` list of files as named modules, and outputs them into the `dir` folder.
  for file in src:
    let trg = file.chgDir(file.splitFile.dir, dir).changeFileExt(".pcm")
    file.direct(trg, flags.cc, quietStr, file.getCC()&" -c")

proc compile *(src :seq[Fil]; trg :Fil; flags :Flags= fl.allPP) :void=
  ## Compiles the given `src` list of files using `gcc`
  ## Assumes the paths given are already relative/absolute in the correct way.
  log &"Building {trg}"
  var objs :seq[Fil]
  var cmds :seq[string]
  var cfl  = flags.cc.join(" ")
  for file in src:
    var trg  = file.chgDir(srcDir, binDir)
    if trg.isObj:  # File is already an object. Add to objs and continue
      objs.add(trg); continue
    trg = trg.toObj(OS.Linux)
    let dir = trg.splitFile.dir
    let cmd = &"{file.getCC()} -MMD {cfl} -c {file} -o {trg}"
    if quiet: echo &"{Cstr} {trg}"
    else:     echo cmd
    objs.add trg
    if not dir.dirExists: createDir dir
    sh cmd
    # cmds.add cmd
  # sh cmds, c.cores
  objs.link(trg, flags)

proc compile *(src :seq[Fil]; obj :BuildTrg) :void=
  case obj.kind
  of Program:  src.compile(obj.trg, obj.flags)
  of Object:   src.compileToObj(obj.root, obj.flags)
  of Module:   src.compileToMod(obj.root, obj.flags)
  of SharedLibrary, StaticLibrary: cerr "Compiling as SharedLibrary and StaticLibrary is not implemented."

