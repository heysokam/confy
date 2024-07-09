//:_____________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
//:_____________________________________________________
//! @fileoverview Package Information Tools
//__________________________________________|
const Package = @This();
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;
const Name = zstd.Name;
// @deps confy
const Git  = @import("./git.zig");


//______________________________________
// @section Package Tools
//____________________________
pub const Info = struct {
  name     :Name,
  author   :Name,
  version  :cstr,
  license  :cstr,
  git      :Git.Info,
};
pub const Dirs = struct {
  root  :cstr= ".",
  bin   :cstr= "bin",
  src   :cstr= "src",
  lib   :cstr= "lib",
  cache :cstr= "cache",
  zig   :cstr= ".zig",
  min   :cstr= ".M",
  nim   :cstr= ".nim",
};

