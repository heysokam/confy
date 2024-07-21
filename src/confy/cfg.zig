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
dir     :ProjectDirs= ProjectDirs{},

const ProjectDirs = struct {
  root  :cstr= ".",
  bin   :cstr= "bin",
  src   :cstr= "src",
  lib   :cstr= "lib",
  cache :cstr= "cache",
  zig   :cstr= ".zig",
  min   :cstr= ".M",
  nim   :cstr= ".nim",
};

// TODO:
// pub fn init(B :*std.Build) cfg {
//   const result :cfg= cfg{};
//   _=B;
//   return result;
// }

