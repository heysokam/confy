#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/os import `/`, execShellCmd
from std/strformat import `&`
from std/strutils import normalize
from std/algorithm import reversed
# @deps confy
import ./types/base
import ./types/build
import ./types/config
import ./log
from ./flags import nil
from ./dependency import nil
from ./systm as sys import cross

#_______________________________________
# @section Command: Type Exports
#_____________________________
export build.Command


#_______________________________________
# @section Command: Data Helpers
#_____________________________
func add *(cmd :var Command; args :varargs[string, `$`]) :var Command {.discardable.}=  cmd.args &= args; return cmd


#_______________________________________
# @section Command: Asm
#_____________________________
func assembly *(_:typedesc[Command];
    trg : BuildTarget;
  ) :Command=
  # FIX: Figure out how to implement assembly commands with the new architecture
  #      Should (likely) use the same api than Object
  if trg.kind != Object: trg.fail CompileError, "Compiling Assembly into non-Object files is not supported."
  result.add trg.cfg.zig.bin
  result.add "cc"
  # Compilation Flags
  # └─ 1. Cross Compilation Flags
  if trg.system.cross or trg.system.explicit:
    result.add sys.toZigTag(trg.system)
  # └─ 2. Internally managed flags
  result.add "-x"
  result.add "assembler-with-cpp"
  # result.add "-fno-leading-underscore"
  # └─ 3. User-defined Flags
  result.add trg.flags.cc
  # Output
  result.add "-o"
  result.add sys.binary(trg)
  # Source Code
  result.add "-c" # Compile only, don't link  (will generate objects)
  result.add trg.src


#_______________________________________
# @section Command: C & C++
#_____________________________
# Command: C.generic
func zigcc (_:typedesc[Command];
    trg : BuildTarget;
    tag : string;
    bin : string = ""; # For archiving only
  ) :Command=
  # Binary & Subcommand
  result.add trg.cfg.zig.bin, tag
  # Archiving: Early Exit
  if tag == "ar":
    result.add "-rc"
    result.add bin
    result.add sys.binary(trg)
    return
  # Options
  if trg.cfg.verbose: result.add "-v"
  if trg.kind == SharedLib: result.add "-shared"
  # Cross Compilation Flags
  if trg.system.cross or trg.system.explicit:
    result.add sys.toZigTag(trg.system)
  # Dependencies Flags
  if trg.deps.len > 0: result.add &"-I{trg.cfg.dirs.lib}"
  for dep in trg.deps:
    let dir = trg.cfg.dirs.lib/dep.name/dep.src
    result.add &"-I{dir}"
  # User Flags
  result.add trg.flags.cc
  result.add trg.flags.ld
  # User Args
  result.add trg.args
  # Source code
  if trg.kind == Object: result.add "-c"
  for file in trg.src: result.add file
  # Output
  result.add "-o"
  result.add sys.binary(trg)
#___________________
func c *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command= Command.zigcc(trg, "cc")
#___________________
func cpp *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command= Command.zigcc(trg, "c++")


#_______________________________________
# @section Command: Zig
#_____________________________
func zig_getModules (trg :BuildTarget) :ArgsList=
  ## @descr Build the arguments list with all the dependencies of trg, starting from root
  if trg.deps.len == 0: return
  # Add all root dependencies as --dep to the resulting command
  for dep in trg.deps: result &= dependency.toZig(dep, trg.cfg.dirs.lib, false)
  # The first module is the root module  (zig -h)
  let entry = trg.src[0] # Always treat the first file as the root/entry file
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
  # Dependencies
  result.add trg.zig_getModules()
  # Compilation Flags
  # └─ 1. Cross Compilation Flags
  if trg.system.cross or trg.system.explicit:
    result.add sys.toZigTag(trg.system)
  # └─ 2. Internally managed flags
  if trg.kind == Program: result.add "-freference-trace"
  # └─ 3. User-defined Flags
  if not trg.cfg.zig.lld   : result.add "-fno-lld"
  if not trg.cfg.zig.llvm  : result.add "-fno-llvm"
  for flag in trg.flags.cc : result.add flag
  for flag in trg.flags.ld : result.add flag
  # User Args
  result.add trg.args
  # Output
  result.add "-femit-bin=" & sys.binary(trg)
  # Source Code
  if trg.kind == UnitTest and trg.deps.len == 0:
    for file in trg.src: result.add file
  elif trg.src.len != 0:
    let start = if trg.deps.len > 0: 1 else: 0   # Skip the entry file when there are dependencies. It is treated as a module root
    for file in trg.src[start..^1]: result.add file
  else:
    if trg.deps.len != 0: trg.fail CompileError, "Unreachable case. Cannot create a Zig command for compiling a target with dependencies and only one source file. Should have triggered a different case"
    result.add trg.src[0]


#_______________________________________
# @section Command: Nim
#_____________________________
func nim_zigcc *(_:typedesc[Command];
    trg : BuildTarget;
  ) :seq[string]=
  ## @descr
  ##  Creates the template command for compiling Nim with ZigCC
  ##
  ##  zigcc  : Path to the zigcc alias binary. Can be relative, absolute or on $PATH
  ##  zigcpp : Path to the zigcpp alias binary. Can be relative, absolute or on $PATH
  ##
  ## @reference
  ##  clang.cppCompiler = "zigcpp"
  ##  clang.cppXsupport = "-std=C++20"
  ##  nim c --cc:clang --clang.exe="zigcc" --clang.linkerexe="zigcc" --opt:speed hello.nim
  if trg.cfg.nim.backend notin {NimBackend.c, NimBackend.cpp}: return
  result.add "-d:zig"
  result.add "--cc:clang"
  result.add &"--clang.exe=\"{trg.cfg.zig.cc}\""
  result.add &"--clang.linkerexe=\"{trg.cfg.zig.cc}\""
  result.add &"--clang.cppCompiler=\"{trg.cfg.zig.cpp}\""
  result.add &"--clang.cppXsupport=\"-std=c++20\""
#_____________________________
func nim *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  # Binary & Subcommand
  result.add trg.cfg.nim.bin, $trg.cfg.nim.backend
  result.add Command.nim_zigcc(trg)
  # Add application type
  case trg.kind
  of SharedLib: result.add "--app:lib"
  of StaticLib: result.add "--app:staticlib"
  else:discard  # FIX: Add gui/console cases
  # Config to nimc Options
  if   trg.cfg.force   : result.add "-f"
  if   trg.cfg.verbose : result.add "--verbosity:2"
  elif trg.cfg.quiet   : result.add @["--verbosity:0", "--hints:off"]
  # Cache & Nimble path
  result.add &"--nimCache:{trg.cfg.nim.cache}"
  result.add &"--NimblePath:{trg.cfg.nimble.cache}"
  # Compilation Flags
  # └─ 1. Cross Compilation Flags
  if trg.system.cross or trg.system.explicit:
    let system_nim = sys.toNim(trg.system)
    result.add &"--os:{system_nim.os}"
    result.add &"--cpu:{system_nim.cpu}"
    let system_zig = sys.toZigTag(trg.system)
    result.add &"--passC:\"{system_zig}\""
    result.add &"--passL:\"{system_zig}\""
  # └─ 2. Internally managed flags
  if not trg.cfg.nim.unsafe.defs: result.add "--experimental:strictDefs"
  if not trg.cfg.nim.unsafe.warnings:
    for flag in flags.nim_StrictWarnings: result.add flag
  if not trg.cfg.nim.unsafe.hints:
    for flag in flags.nim_StrictHints: result.add flag
  if trg.cfg.nim.unsafe.functionPointers:
    if trg.cfg.quiet : result.add "--passC:-Wno-incompatible-function-pointer-types"
    else             : result.add "--passC:-Wno-error=incompatible-function-pointer-types"
  # └─ 3. User-defined Optimization
  let mode = ($trg.mode.kind).normalize()
  let opt  = ($trg.mode.opt).normalize()
  result.add &"-d:{mode}"
  result.add &"--opt:{opt}"
  if trg.mode.kind == Debug : result.add "--debugger:native"
  if trg.mode.strip         : result.add "-d:strip"
  if trg.mode.lto           : result.add "-d:lto"
  # └─ 4. User-defined Flags
  for flag in trg.flags.cc: result.add &"--passC:\"{flag}\""
  for flag in trg.flags.ld: result.add &"--passL:\"{flag}\""
  # Dependencies
  result.add trg.deps.toNim(trg.cfg.dirs.lib)
  # Output
  result.add &"--out:{sys.outBin(trg)}"
  result.add &"--outDir:{sys.outDir(trg)}"
  # User Args
  result.add trg.args
  # Source code
  for file in trg.src: result.add file


#_______________________________________
# @section Command: Minim
#_____________________________
func minim *(_:typedesc[Command];
    trg : BuildTarget;
  ) :Command=
  # TODO: Implement support for minim when its compiler cli is implemented
  discard


#_______________________________________
# @section Command: Build
#_____________________________
func build *(_:typedesc[Command];
    trg :BuildTarget;
  ) :Command=
  result = case trg.lang
    of Lang.C     : Command.c(trg)
    of Lang.Zig   : Command.zig(trg)
    of Lang.Cpp   : Command.cpp(trg)
    of Lang.Nim   : Command.nim(trg)
    of Lang.Asm   : Command.assembly(trg)
    of Lang.Minim : Command.minim(trg)
    else:Command()


#_______________________________________
# @section Command: Build
#_____________________________
func archive *(_:typedesc[Command];
    trg : BuildTarget;
    bin : string;
  ) :Command=
  ## @descr Returns the command that must be run for archiving the intermediate objects of C targets
  Command.zigcc(trg, "ar", bin)


#_______________________________________
# @section Command: Run
#_____________________________
func run *(_:typedesc[Command];
    trg   :BuildTarget;
    args  :ArgsList= @[];
  ) :Command=
  ## @descr Create a run command for the {@arg trg} that will pass {@arg args} to the binary
  result = Command()
  result.add sys.binary(trg)
  result.add args
#___________________
proc run *(cmd :Command) :int {.discardable.}= return sys.exec(cmd)

