//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Package Information Tools
//__________________________________________|
const Package = @This();
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;
const Name = zstd.Name;
// @deps confy
const Git = @import("./git.zig");


//______________________________________
// @section Package Metadata
//____________________________
/// @descr Describes metadata/information about a Package, and provides tool to manage it.
pub const Info = struct {
  name     :Name,
  author   :Name,
  version  :cstr,
  license  :cstr,
  git      :Git.Info,
};

//______________________________________
// @section Package Folders
//____________________________
/// @descr Describes the folder structure of a Package, and provides tool to manage it.
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

