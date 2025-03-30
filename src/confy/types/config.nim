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
  bin    *:PathLike=  cfg.dirs_bin
  src    *:PathLike=  cfg.dirs_src
  sub    *:PathLike=  ""
  tests  *:PathLike=  cfg.dirs_bin/cfg.dirs_tests
  lib    *:PathLike=  cfg.dirs_bin/cfg.dirs_lib
  cache  *:PathLike=  cfg.dirs_bin/cfg.dirs_cache

type Zig * = object
  bin        *:PathLike=  cfg.dirs_bin/cfg.zig_dir
  cache      *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.zig_dir
  systemBin  *:bool    =  false

type NimBackend *{.pure.}= enum c, cpp, js
type Nim * = object
  bin       *:PathLike  =  cfg.dirs_bin/cfg.nim_dir
  cache     *:PathLike  =  cfg.dirs_bin/cfg.dirs_cache/cfg.nim_dir
  backend   *:NimBackend=  NimBackend.c
  systemBin *:bool      =  false

type Nimble * = object
  bin       *:PathLike=  cfg.dirs_bin/cfg.nimble_dir
  cache     *:PathLike=  cfg.dirs_bin/cfg.dirs_cache/cfg.nimble_dir
  systemBin *:bool    =  false

type Config * = object
  dirs    *:Dirs
  zig     *:Zig
  nim     *:Nim
  nimble  *:Nimble

