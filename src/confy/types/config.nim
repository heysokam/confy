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

type Dirs * = object
  root   *:PathLike=  "."
  bin    *:PathLike=  cfg.dirs_bin
  src    *:PathLike=  cfg.dirs_src
  tests  *:PathLike=  cfg.dirs_bin/cfg.dirs_tests
  lib    *:PathLike=  cfg.dirs_bin/cfg.dirs_lib
  cache  *:PathLike=  cfg.dirs_bin/cfg.dirs_cache

type Zig * = object
  bin        *:PathLike=  cfg.dirs_bin/cfg.zig_dir/cfg.zig_bin
  cache      *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.zig_name
  systemBin  *:bool    =  false

type NimUnsafe * = object
  ## @descr Unsafe (optional) flags that can be added to a Nim BuildTarget to ignore safety flags.
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
  systemBin  *:bool=  false ## @descr
    ##  Uses the System's Nim path, without downloading a new version from the web.
    ##  @when on : Uses the system's nim like `nim c file.nim`
    ##  @when off: Runs the nim compiler setup logic and executes the nim compiler like `cfg.nimDir/bin/nim c file.nim`
    ##  @default:off
    ##   Can cause confusion for nim users.
    ##   They will expect it `on` because both the nim compiler and nimble work that way.
  unsafe  *:NimUnsafe=  NimUnsafe() ## @descr
    ##  Unsafe (optional) flags that can be added to a Nim BuildTarget to ignore ZigCC safety flags.


type Nimble * = object
  bin       *:PathLike=  cfg.dirs_bin/cfg.nimble_dir/"bin"/cfg.nimble_bin
  cache     *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.nimble_dir
  systemBin *:bool    =  false

type Git * = object
  bin       *:PathLike=  cfg.git_bin
  systemBin *:bool    =  true

type Config * = object
  # Builder Options
  prefix  *:string = cfg.tool_prefix
  verbose *:bool   = cfg.tool_verbose
  quiet   *:bool   = cfg.tool_quiet
  force   *:bool   = cfg.tool_force
  # Project Options
  dirs    *:Dirs
  # Compiler/Tools Options
  git     *:Git
  zig     *:Zig
  nim     *:Nim
  nimble  *:Nimble

