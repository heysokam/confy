//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Confy's Configuration Management tools
//_______________________________________________________|
pub const cfg = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;

prefix  :cstr= "ᛝ confy:",
verbose :bool= false,
quiet   :bool= false,
force   :bool= false,
dir     :ProjectDirs= ProjectDirs{},
nim     :Nim= Nim{},

const ProjectDirs = struct {
  root  :cstr= ".",
  bin   :cstr= "bin",
  src   :cstr= "src",
  lib   :cstr= "./bin/.lib",
  cache :cstr= ".cache",
  zig   :cstr= ".zig",
  min   :cstr= ".M",
  nim   :cstr= ".nim",
}; //:: cfg.ProjectDirs

const Nim = struct {
  zigcc  :cstr= "zigcc",
  zigcpp :cstr= "zigcpp",
  unsafeFunctionPointers :bool= false,
}; //:: cfg.Nim

