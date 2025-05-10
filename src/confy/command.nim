#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`, execShellCmd
from std/strutils  import join
from std/strformat import `&`
from std/algorithm import reversed
# @deps confy
import ./types/base
import ./types/build
import ./log
from ./flags import nil
from ./dependency import nil

#_______________________________________
# @section Command Type Exports
#_____________________________
export build.Command


#_______________________________________
# @section Command Helpers
#_____________________________
func getBinary *(trg :BuildTarget) :PathLike= trg.cfg.dirs.bin/trg.sub/trg.trg
#___________________
func exec *(cmd :Command) :int {.discardable.}=
  log.info "Executing command:\n  ", cmd.args.join(" ")
  return os.execShellCmd cmd.args.join(" ")
#___________________
func add *(cmd :var Command; args :varargs[string, `$`]) :var Command {.discardable.}=  cmd.args &= args; return cmd


#_______________________________________
# @section C
#_____________________________
func c *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.add trg.cfg.zig.bin, "cc"
  # Options
  if trg.cfg.verbose: result.add "-v"
  # Flags
  result.add flags.C
  # User Args
  result.add trg.args
  # Source code
  for file in trg.src: result.add trg.cfg.dirs.src/file
  # Output
  result.add "-o"
  result.add trg.getBinary()


#_______________________________________
# @section C++
#_____________________________
func cpp *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.add trg.cfg.zig.bin, "c++"
  # Options
  if trg.cfg.verbose: result.add "-v"
  # Flags
  result.add flags.Cpp
  # User Args
  result.add trg.args
  # Source code
  for file in trg.src: result.add trg.cfg.dirs.src/file
  # Output
  result.add "-o"
  result.add trg.getBinary()


#_______________________________________
# @section Zig
#_____________________________
func zig_getModules (trg :BuildTarget) :ArgsList=
  ## @descr Build the arguments list with all the dependencies of trg, starting from root
  if trg.deps.len == 0: return
  # Add all root dependencies as --dep to the resulting command
  for dep in trg.deps: result &= dependency.toZig(dep, trg.cfg.dirs.lib, false)
  # The first module is the root module  (zig -h)
  let entry = trg.cfg.dirs.src/trg.src[0] # Always treat the first file as the root/entry file
  result.add &"-M{trg.trg}={entry}"
  # Add the dependencies in reverse order
  for dep in trg.deps.reversed: result &= dependency.toZig(dep, trg.cfg.dirs.lib, true)

#___________________
func zig *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.add trg.cfg.zig.bin
  case trg.kind
  of SharedLib,
     StaticLib : result.add "build-lib"
  of Program   : result.add "build-exe"
  of UnitTest  : result.add "test"
  else:discard
  # Cache
  result.add [       "--cache-dir", trg.cfg.zig.cache]
  result.add ["--global-cache-dir", trg.cfg.zig.cache]
  # Flags
  if trg.kind == Program: result.add "-freference-trace"
  # Dependencies
  result.args &= trg.zig_getModules()
  # User Args
  result.args &= trg.args
  # Output
  result.add "-femit-bin=" & trg.getBinary()
  # Source Code
  case trg.kind
  of UnitTest:
    for file in trg.src: result.add trg.cfg.dirs.src/file
  else:
    if trg.src.len > 1:  # Always skip the entry file. It is treated as a module root
      let start = if trg.src.len > 1: 1 else: 0
      for file in trg.src[start..^1]: result.add trg.cfg.dirs.src/file


#_______________________________________
# @section Zig
#_____________________________
func nim *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.add trg.cfg.nim.bin, $trg.cfg.nim.backend
  # Cache & Nimble path
  result.add &"--nimCache:{trg.cfg.nim.cache}"
  result.add &"--NimblePath:{trg.cfg.nimble.cache}"
  # Flags
  result.add []
  # Dependencies
  result.add trg.deps.toNim(trg.cfg.dirs.lib)
  # Output
  let outDir = trg.cfg.dirs.bin/trg.sub
  result.add &"--out:{trg.trg}"
  result.add &"--outDir:{outDir}"
  # User Args
  result.add trg.args
  # Source code
  for file in trg.src: result.add trg.cfg.dirs.src/file


#_______________________________________
# @section Build Command Manager
#_____________________________
func build *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  result = case trg.lang
    of Lang.C   : Command.c(trg)
    of Lang.Zig : Command.zig(trg)
    of Lang.Cpp : Command.cpp(trg)
    of Lang.Nim : Command.nim(trg)
    else:Command()


#_______________________________________
# @section Run Command Manager
#_____________________________
func run *(_:typedesc[Command];
    trg   :BuildTarget;
    args  :ArgsList= @[];
  ) :Command=
  ## @descr Create a run command for the {@arg trg} that will pass {@arg args} to the binary
  result = Command()
  result.add trg.getBinary()
  result.add args
#___________________
proc run *(cmd :Command) :int {.discardable.}= return cmd.exec()

