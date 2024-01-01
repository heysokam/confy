#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/strformat
# @deps confy
import ../types
import ../cfg
import ../dirs
import ../tool/paths
import ../tool/logger
import ../tool/helper as t
# @deps confy.builder
import ./helper
# @deps confy.builder.zigcc
import ./zigcc/zcfg
import ./zigcc/bin as z


#_____________________________________________________
# Nim: General Config
#_____________________________
let zigcc      = cfg.zigDir/"zigcc"
let zigcpp     = cfg.zigDir/"zigcpp"
let zigccSrc   = cfg.cacheDir/"zigcc.nim"
let zigcppSrc  = cfg.cacheDir/"zigcpp.nim"


#_____________________________________________________
# NimZ Compiler : Alias Manager
#_____________________________
let nimcZopts = "c -d:release --hint:Conf:off --hint:Link:off --skipProjCfg --skipParentCfg" # Base nimc command to build zigcc and zigcpp binaries with
const ZigccTemplate = """
# From: https://github.com/enthus1ast/zigcc
import std/os
import std/osproc
# Set the zig compiler to call, append args, and Start the process
let process = startProcess(
  command = r"{zcfg.getRealBin()}",                 # Path of the real Zig binary
  args    = @["{CC}"] & commandLineParams(),  # Add the suffix and all commandLineParams to the command
  options = {{poStdErrToStdOut, poUsePath, poParentStreams}},
  ) # << startProcess( ... )
# Get the code so we can carry across the exit code
let exitCode = process.waitForExit()
# Clean up
close process
quit exitCode
"""
proc writeZigcc(rebuild:bool)=
  ## Write the zigcc source code file if it doesn't exist
  let CC = "cc"
  if rebuild or not zigccSrc.fileExists:
    if verbose: log &"{zigccSrc.string} does not exist. Writing it..."
    writeFile( zigccSrc.string,  fmt(ZigccTemplate) )
proc writeZigcpp(rebuild:bool)=
  ## Write the zigcpp source code file if it doesn't exist
  let CC = "c++"
  if rebuild or not zigcppSrc.fileExists:
    if verbose: log &"{zigccSrc.string} does not exist. Writing it..."
    writeFile( zigcppSrc.string, fmt(ZigccTemplate) )
proc buildZigcc(rebuild:bool)=
  ## Build the zigcc binary if it doesn't exist
  if rebuild or not zigcc.fileExists:
    let cmd = cfg.nim.cc & &" {nimcZopts} --out:{zigcc.lastPathPart} --outDir:{cfg.zigDir} {zigccSrc.string}"
    if verbose: log &"{zigcc} does not exist. Creating it with:\n  {cmd}"
    sh cmd
  elif verbose: log &"{zigcc.lastPathPart} is up to date."
proc buildZigcpp(rebuild:bool)=
  ## Build the zigcpp binary if it doesn't exist
  if rebuild or not zigcpp.fileExists:
    let cmd = cfg.nim.cc & &" {nimcZopts} --out:{zigcpp.lastPathPart} --outDir:{cfg.zigDir} {zigcppSrc.string}"
    if verbose: log &"{zigcpp} does not exist. Creating it with:\n  {cmd}"
    sh cmd
  elif verbose: log &"{zigcpp.lastPathPart} is up to date."
#_____________________________
proc buildNimZ  *(force=false) :void=
  ## Writes and builds the source code of both NimZ aliases when they do not exist.
  let rebuild = z.initOrExists(force=force)
  writeZigcc(rebuild) ; writeZigcpp(rebuild)
  buildZigcc(force)   ; buildZigcpp(force)


#_____________________________________________________
# NimZ Compiler : Builder
#_____________________________
# clang.cppCompiler = "zigcpp"
# clang.cppXsupport = "-std=C++20"
# nim c --cc:clang --clang.exe="zigcc" --clang.linkerexe="zigcc" --opt:speed hello.nim
#_____________________________
const ZigTemplate = "{cc} --nimcache:{cfg.cacheDir} -d:zig --cc:clang --clang.exe=\"{zigcc}\" --clang.linkerexe=\"{zigcc}\" --clang.cppCompiler=\"{zigcpp}\" --clang.cppXsupport=\"-std=c++20\" {zigTarget}"
#_____________________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool= false) :void=
  if obj.kind == Object: cerr "Compiling Nim into Object files is not supported. Run nim manually with `--noLinking:on|off`"
  buildNimZ(force=force) # Build the NimZ aliases when they do not exist
  var zigTarget :string
  if obj.syst != getHost():
    let zigSyst = obj.syst.toZig
    let nimSyst = obj.syst.toNim
    zigTarget.add &"--os:{nimSyst.os} --cpu:{nimSyst.cpu} "
    zigTarget.add &"--passC:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
    zigTarget.add &"--passL:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
  let typFlag = case obj.kind
    of SharedLibrary : "--app:lib"
    of StaticLibrary : "--app:staticlib"
    else             : ""
  let verb = if cfg.verbose: "--verbosity:3" else:""
  var cc = &"{cfg.nim.cc} {cfg.nim.backend} {verb} {typFlag}"
  if force: cc &= " -f"
  case  obj.cc  # Add extra parameters for the compilers when required
  of    Zig:    cc = fmt(ZigTemplate)
  of    GCC:    cc &= " --cc:gcc"
  of    Clang:  cc &= " --cc:clang"
  if cfg.nim.unsafe.functionPointers: cc.add " --passC:-Wno-incompatible-function-pointer-types"
  let cmd = &"{cc} --out:{obj.trg.toBin(obj.syst.os)} --outdir:\"{obj.root/obj.sub}\" {obj.args} {obj.src.join()}"
  if cfg.verbose     : echo cmd
  elif not cfg.quiet : echo &"{cfg.Cstr} {obj.trg}"
  echo cmd
  sh cmd

