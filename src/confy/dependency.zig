//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Dependency Management
//______________________________________|
pub const Dependency = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;

name :cstr,
url  :cstr,
deps :?[]const Dependency= null,
opts :Dependency.Options= .{},

/// @descr Describes a sequence/list of {@link Dependency} objects
pub const List = zstd.seq(Dependency);

/// @descr Dependency Configuration Defaults
pub const default = struct {
  const src_subDir = "src";
};

pub const Options = struct{
  /// @descr Source code folder where the root file is stored
  src        :cstr=  Dependency.default.src_subDir,
  /// @descr
  ///  Path of the file that should be treated as the root/entry point of the dependency
  ///  Will use {@link Dependency.name}+".ext" when omitted.
  ///  Must be relative to {@link Options.src}.
  root       :?cstr=  null,
  /// @descr Whether the dependency should be treated as a git submodule or not.
  submodule  :bool=  false,
  /// @descr
  ///  When not null, override the target's default lib installation subpath with this folder
  ///  Must be relative to the current working directory _(`std.path.cwd()`)_ from where the builder is run.
  /// @note _Provided for completion. This option should almost never be needed._
  libDir     :?cstr=  null,
  /// @descr Subdependencies of this dependency. Only for construction, ignored everywhere else.
  deps       :?[]const Dependency= null,
}; //:: Dependency.Options

pub fn toNim (
    S : *const Dependency,
    D : cstr,
    A : std.mem.Allocator,
  ) !cstr {
  if (S.opts.src.len == 0) { return try std.fmt.allocPrint(A, "--path:{s}/{s}",     .{D, S.name});               }
  else                     { return try std.fmt.allocPrint(A, "--path:{s}/{s}/{s}", .{D, S.name, S.opts.src}); }
} //:: Dependency.toNim

const zig = struct {
  fn depOrModule (
      S : *const Dependency,
      D : cstr,
      M : bool,
      R : *zstd.str,
    ) !void {
    try R.appendSlice(if (M) " -M" else " --dep ");
    try R.appendSlice(S.name);
    if (!M) return;
    try R.append('=');
    try R.appendSlice(D);
    try R.append('/');
    try R.appendSlice(S.name);
    try R.append('/');
    try R.appendSlice(S.opts.src);
    try R.append('/');
    try R.appendSlice(S.opts.root orelse S.name);
    try R.appendSlice(".zig");
  }

  /// @descs Adds the given {@arg L} list of dependencies as `--dep name` at the end of the {@arg R} resulting string
  fn getDependencies (
      L : Dependency.List,
      R : *zstd.str,
    ) !void {
    if (L.items.len == 0) return;
    for (L.items) |dep| {
      try R.appendSlice(" --dep ");
      try R.appendSlice(dep.name);
    }
  }

  fn args (
      S    : *const Dependency,
      D    : cstr,
      root : bool,
      R    : *zstd.str,
    ) !void {
    for (S.deps orelse &.{}) |dep| std.debug.print("{s} ", .{dep.name});
    // Add the dependencies as --dep
    if (S.deps != null) for (S.deps.?) |dep| try zig.depOrModule(&dep, D, false, R);
    // Add the root at the end
    try zig.depOrModule(S, D, root, R);
  }
};
pub const toZig      = zig.args;
pub const getZigDeps = zig.getDependencies;


// TODO:
// pub fn clone(S :*const Dependency) void {
//   std.debug.print("...............\n", .{});
//   std.debug.print("Dependency.clone\n", .{});
//   std.debug.print("{s}\n", .{S.name});
//   std.debug.print("{s}\n", .{S.url});
//   std.debug.print("{s}\n", .{S.src});
//   std.debug.print("...............\n", .{});
// }

