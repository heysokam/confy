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
import ../logger
import ../dirs
# Builder Module dependencies
import ./base as baseBuilder ; export baseBuilder


#_____________________________
let   cc  = if verbose: "gcc -v" else: "gcc"
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
  else: raise newException(IOError, &"Support for {os} is currently not implemented.")
#_____________________________
proc isObj (trg :Fil) :bool=  trg.endsWith(".o")
  ## Returns true if the `trg` file is already a compiled object.


# addFileExt proc

# >>  Remember to add executable flags to the resulting binaries


#_____________________________
# GCC: Internal
#___________________
proc direct (src :seq[Fil]; trg :Fil; quietStr :string) :void=
  ## Builds the `src` list of files directly into the `trg` file.
  ## Doesn't compile an intermediate `.o` step.
  let files = src.join(" ")
  let cmd   = &"{cc} {files} -o {trg}"
  if quiet: echo &"{quietStr} {trg}"
  else:     echo cmd
  sh cmd

#_____________________________
# GCC: Linker
#___________________
proc link *(src :seq[Fil]; trg :Fil) :void=  direct(src, trg, Lstr)
  ## Links the given `src` list of files into the `trg` binary.

#_____________________________
# GCC: Compiler
#___________________
proc compileNoObj *(src :seq[Fil]; trg :Fil) :void=  direct(src, trg, Cstr)
  ## Compiles the given `src` list of files using `gcc` into the `trg` binary.
  ## Doesn't compile an intermediate `.o` step.

proc compile *(src :var seq[Fil]; trg :Fil) :void=
  ## Compiles the given `src` list of files using `gcc`
  ## Assumes the paths given are already relative/absolute in the correct way.
  log &"Building {trg}"
  var objs :seq[Fil]
  var cmds :seq[string]
  for file in src:
    var trg = file.chgDir(srcDir, binDir)
    echo trg
    if trg.isObj:  # File is already an object. Add to objs and continue
      objs.add(trg); continue
    trg = trg.toObj(OS.Linux)
    let dir = trg.splitFile.dir
    let cmd = &"{cc} -MMD -c {file} -o {trg}"
    if quiet: echo &"{Cstr} {trg}"
    else:     echo cmd
    objs.add trg
    if not dir.dirExists: createDir dir
    sh cmd
    # cmds.add cmd
  # sh cmds, c.cores
  objs.link(trg)

