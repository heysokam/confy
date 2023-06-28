#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os except `/`
import std/strformat
import std/enumutils
# confy dependencies
import ../types
import ../cfg
import ../dirs
import ../tool/logger
import ../tool/helper as h
import ./helper


#_____________________________________________________
# Nim: General Config
#_____________________________
let nimc      = if cfg.verbose: "nim c --verbosity:3" else: "nim c"
let zigcc     = cfg.zigDir/"zigcc"
let zigcpp    = cfg.zigDir/"zigcpp"
let zigccSrc  = cfg.cacheDir/"zigcc.nim"
let zigcppSrc = cfg.cacheDir/"zigcpp.nim"


#_____________________________________________________
# NimZ Compiler : Alias Manager
#_____________________________
const ZigccTemplate = """
# From: https://github.com/enthus1ast/zigcc
import std/os
import std/osproc
# Set the zig compiler to call, append args, and Start the process
let process = startProcess(
  command = "{cfg.zigDir}"/"zig",             # Path of the real Zig binary
  args    = @["{CC}"] & commandLineParams(),  # Add the suffix and all commandLineParams to the command
  options = {{poStdErrToStdOut, poUsePath, poParentStreams}},
  ) # << startProcess( ... )
# Get the code so we can carry across the exit code
let exitCode = process.waitForExit()
# Clean up
close process
quit exitCode
"""
proc writeZigcc=
  ## Write the zigcc source code file if it doesn't exist
  let CC = "cc"
  if not zigccSrc.fileExists:
    if verbose: log &"{zigccSrc} does not exist. Writing it..."
    writeFile( zigccSrc,  fmt(ZigccTemplate) )
proc writeZigcpp=
  ## Write the zigcpp source code file if it doesn't exist
  let CC = "c++"
  if not zigcppSrc.fileExists:
    if verbose: log &"{zigccSrc} does not exist. Writing it..."
    writeFile( zigcppSrc, fmt(ZigccTemplate) )
proc buildZigcc=
  ## Build the zigcc binary if it doesn't exist
  if not zigcc.fileExists:
    let cmd = &"nim c -d:release --out:{zigcc.lastPathPart} --outDir:{cfg.zigDir} {zigccSrc}"
    if verbose: log &"{zigcc} does not exist. Creating it with:\n  {cmd}"
    sh cmd
  elif verbose: log &"{zigcc.lastPathPart} is up to date."
proc buildZigcpp=
  ## Build the zigcpp binary if it doesn't exist
  if not zigcpp.fileExists:
    let cmd = &"nim c -d:release --out:{zigcpp.lastPathPart} --outDir:{cfg.zigDir} {zigcppSrc}"
    if verbose: log &"{zigcpp} does not exist. Creating it with:\n  {cmd}"
    sh cmd
  elif verbose: log &"{zigcpp.lastPathPart} is up to date."
#_____________________________
proc buildNimZ  *() :void=
  ## Writes and builds the source code of both NimZ aliases when they do not exist.
  writeZigcc() ; writeZigcpp()
  buildZigcc() ; buildZigcpp()


#_____________________________________________________
# NimZ Compiler : Builder
#_____________________________
# clang.cppCompiler = "zigcpp"
# clang.cppXsupport = "-std=C++20"
# nim c --cc:clang --clang.exe="zigcc" --clang.linkerexe="zigcc" --opt:speed hello.nim
#_____________________________
const ZigTemplate = "{cc} -d:zig --cc:clang --clang.exe=\"{zigcc}\" --clang.linkerexe=\"{zigcc}\" --clang.cppCompiler=\"{zigcpp}\" --clang.cppXsupport=\"-std=c++20\" {zigTarget}"
#_____________________________
proc compile *(src :seq[DirFile]; obj :BuildTrg; force :bool= false) :void=
  buildNimZ() # Build the NimZ aliases when they do not exist
  var zigTarget :string
  if obj.syst != getHost():
    let zigSyst = obj.syst.toZig
    let nimSyst = obj.syst.toNim
    zigTarget.add &"--os:{nimSyst.os} --cpu:{nimSyst.cpu} "
    zigTarget.add &"--passC:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
    zigTarget.add &"--passL:\"-target {zigSyst.cpu}-{zigSyst.os}\" "
  var cc = nimc
  if force: cc &= " -f"
  case  obj.cc  # Add extra parameters for the compilers when required
  of    Zig:    cc = fmt(ZigTemplate)
  of    GCC:    cc &= " --cc:gcc"
  of    Clang:  cc &= " --cc:clang"
  else: discard
  let cmd = &"{cc} --outdir:{obj.root} --out:{obj.trg} {obj.src.join()}"
  if not quiet: echo &"{cfg.Cstr} {obj.trg}"
  elif verbose: echo cmd
  sh cmd

