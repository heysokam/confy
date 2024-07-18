//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Submodule Management
//______________________________________|
pub const Submodule = @This();
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;

name :cstr,
url  :cstr,
src  :cstr= default.src_subDir,

/// @descr Describes a sequence/list of {@link Submodule} objects
pub const List = zstd.seq(Submodule);

/// @descr Submodule Configuration Defaults
pub const default = struct {
  const src_subDir = "src";
};

pub fn new(args :struct{
    name : cstr,
    url  : cstr,
    src  : cstr = default.src_subDir,
  }) Submodule {
  return Submodule{
    .name = args.name,
    .url  = args.url,
    .src  = args.src,
  };
}

// pub fn clone(S :*const Submodule) void {
//   std.debug.print("...............\n", .{});
//   std.debug.print("Submodule.clone\n", .{});
//   std.debug.print("{s}\n", .{S.name});
//   std.debug.print("{s}\n", .{S.url});
//   std.debug.print("{s}\n", .{S.src});
//   std.debug.print("...............\n", .{});
// }

