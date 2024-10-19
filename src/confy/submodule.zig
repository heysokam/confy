//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Submodule Management
//______________________________________|
pub const Submodule = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;

name :cstr,
url  :cstr,
src  :?cstr= Submodule.default.src_subDir,

/// @descr Describes a sequence/list of {@link Submodule} objects
pub const List = zstd.seq(Submodule);

/// @descr Submodule Configuration Defaults
pub const default = struct {
  const src_subDir = "src";
};

pub fn new (in :struct{
    name : cstr,
    url  : cstr,
    src  : ?cstr = Submodule.default.src_subDir,
  }) Submodule {
  return Submodule{
    .name = in.name,
    .url  = in.url,
    .src  = in.src,
  };
}

pub fn toNim (
    S : *const Submodule,
    D : cstr,
    A : std.mem.Allocator,
  ) !cstr {
  if (S.src == null) { return try std.fmt.allocPrint(A, "--path:{s}/{s}",     .{D, S.name});          }
  else               { return try std.fmt.allocPrint(A, "--path:{s}/{s}/{s}", .{D, S.name, S.src.?}); }
} //:: Submodule.toNim

// pub fn clone(S :*const Submodule) void {
//   std.debug.print("...............\n", .{});
//   std.debug.print("Submodule.clone\n", .{});
//   std.debug.print("{s}\n", .{S.name});
//   std.debug.print("{s}\n", .{S.url});
//   std.debug.print("{s}\n", .{S.src});
//   std.debug.print("...............\n", .{});
// }

