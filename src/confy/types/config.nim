#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @fileoverview Configuration Types
#____________________________________|
# @deps std
from std/os import `/`
# @deps confy
import ./base
from ../cfg import nil
from ../tools/git import nil
from ../package import nil


#_______________________________________
# @section Folders
#_____________________________
type Dirs * = object
  root   *:PathLike=  "."
  bin    *:PathLike=  cfg.dirs_bin
  src    *:PathLike=  cfg.dirs_src
  tests  *:PathLike=  cfg.dirs_bin/cfg.dirs_tests
  lib    *:PathLike=  cfg.dirs_bin/cfg.dirs_lib
  cache  *:PathLike=  cfg.dirs_bin/cfg.dirs_cache


#_______________________________________
# @section Zig
#_____________________________
const zig_dir = cfg.dirs_bin/cfg.zig_dir  # Internal alias to not repeat the default assignments code
type Zig * = object
  bin        *:PathLike=  zig_dir/cfg.zig_bin
  cc         *:PathLike=  zig_dir/cfg.zig_cc
  cpp        *:PathLike=  zig_dir/cfg.zig_cpp
  ar         *:PathLike=  zig_dir/cfg.zig_ar
  lld        *:bool    =  cfg.zig_llvm
  llvm       *:bool    =  cfg.zig_llvm
  cache      *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.zig_name
  systemBin  *:bool    =  cfg.all_systemBin


#_______________________________________
# @section Nim
#_____________________________
type NimUnsafe * = object
  ## @descr Unsafe (optional) flags that can be added to a Nim BuildTarget to ignore safety flags.
  defs  *:bool= false ## @descr
    ##  When active, the flag --strictDefs:on will not be added to the compiler options
    ##  https://nim-lang.org/docs/manual_experimental.html#strict-definitions-and-nimout-parameters
  warnings  *:bool= false ## @descr
    ##  When true, warnings will not be treated as errors by the Nim compiler.
    ##  @note Does not change the behavior of `User` warnings
    ##  @note
    ##   This safety option works by explicitely adding all warnings as --warningAsError:X
    ##   Set this option to true to disable this feature, or add --warningAsError:X:off to the target.args list to disable individual ones
  hints  *:bool= false ## @descr
    ##  When true, safety hints will not be treated as errors by the Nim compiler.
    ##  @note Only a handpicked list of hints will be marked as errors
    ##  @note
    ##   This safety option works by explicitely adding the hints as --hintAsError:X
    ##   Set this option to true to disable this feature, or add --hintAsError:X:off to the target.args list to disable individual ones
  functionPointers  *:bool= false ## @descr
    ##  When active, the flag `-Wno-incompatible-function-pointer-types` will be passed to ZigCC for compiling nim code.
    ##  The correct fix for this unsafety is done in wrapper code. ZigCC is just pointing at incorrectly written code.
    ##  This config option exists for ergonomics. The same behavior can be achieved with:
    ##  `someBuildTarget.args = @["-Wno-incompatible-function-pointer-types"]`

type NimBackend *{.pure.}= enum c, cpp, objc, js
type Nim * = object
  bin  *:PathLike=  cfg.dirs_bin/cfg.nim_dir/"bin"/cfg.nim_bin ## @descr
    ##  Binary that confy will call when it needs to run `nim [options]`
    ##  Can be a binary in PATH, or an absolute or relative path
    ##  @default "nim" Relies on nim being installed on PATH
  cache  *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.nim_dir ## @descr
    ##  Folder where the temporary compilation outputs of nim will be stored.
    ##  Will be used as  --nimCache:path/to/dir
  backend  *:NimBackend=  NimBackend.c ## @descr
    ##  Backend that the nim compiler will use to build the project.
    ##  @note Only applies to the project files. The builder app always compiles with the `nim c` backend.
  systemBin  *:bool=  cfg.all_systemBin ## @descr
    ##  Uses the System's Nim path, without downloading a new version from the web.
    ##  @when on : Uses the system's nim like `nim c file.nim`
    ##  @when off: Runs the nim compiler setup logic and executes the nim compiler like `cfg.nimDir/bin/nim c file.nim`
    ##  @default:off
    ##   Can cause confusion for nim users.
    ##   They will expect it `on` because both the nim compiler and nimble work that way.
  systemZigCC  *:bool=  cfg.all_systemBin ## @descr
    ##  Uses the System's PATH to find `zigcc`, `zigcpp` and `zigar` binaries when true
  unsafe  *:NimUnsafe=  NimUnsafe() ## @descr
    ##  Unsafe (optional) flags that can be added to a Nim BuildTarget to ignore ZigCC safety flags.


#_______________________________________
# @section Nimble
#_____________________________
type Nimble * = object
  bin       *:PathLike=  cfg.dirs_bin/cfg.nim_dir/"bin"/cfg.nimble_bin
  cache     *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.nimble_dir/"pkgs2"
  systemBin *:bool    =  cfg.all_systemBin


#_______________________________________
# @section Git
#_____________________________
type Git * = object
  bin  *:PathLike= cfg.git_bin ## @descr
    ##  Binary to call for running `git` tasks.
  repo *:git.Repository ## @descr
    ##  Git Repository where the Project is stored
  systemBin  *:bool= true


#_______________________________________
# @section Configuration Options
#_____________________________
type Config * = object
  # Builder Options
  prefix  *:string= cfg.tool_prefix ## @descr
    ##  Prefix that will be added at the start of every command output.
  verbose *:bool= cfg.tool_verbose ## @descr
    ##  Output will be fully verbose when active.
  quiet   *:bool= cfg.tool_quiet ## @descr
    ##  Output will be formatted in a minimal clean style when active.
  force   *:bool= cfg.tool_force ## @descr
    ##  Force-compile ignoring the cache on every run of the builder when true.
  # Project Options
  dirs    *:Dirs
  # Compiler/Tools Options
  git     *:Git
  zig     *:Zig
  nim     *:Nim
  nimble  *:Nimble
  pkg     *:package.Info
  # TODO:
  # fakeRun  *:bool= false  ## @descr
  #   ##  Everything will happen normally, except that no commands will be executed.

