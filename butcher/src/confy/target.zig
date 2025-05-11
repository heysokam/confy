//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Describes the metadata and tools to create a confy Build Target.
//____________________________________________________________________|
pub const BuildTrg = @This();
// @deps std
const std = @import("std");
// @deps confy
const zig          = @import("./target/zig.zig");
const C            = @import("./target/C.zig");
const nim          = @import("./target/nim.zig");
const language     = @import("./target/language.zig");
const Cfg          = @import("./cfg.zig");
const Dependency   = @import("./dependency.zig");
const Dependencies = Dependency.List;
const Confy        = @import("./core.zig");
const CodeList     = @import("./code.zig");
const FlagList     = @import("./flags.zig");



/// @descr
///  Options to configure the building process. Provides sane defaults when implicit.
///  _Shouldn't be needed unless you need extra-explicit configuration options for some very specific reason._
pub const BuildOptions = struct {
  /// @descr Appends the CPU architecture of the system to the final binary, right before its extension
  /// @example
  ///  trg.bin    : thing
  ///  system.Cpu : x86_64
  ///  output     : thingx86_64.ext
  appendCpu  :bool=  false,
};

pub fn getObj (trg :*const BuildTrg, system :System, opts:BuildOptions) !cstr {
  if (trg.kind == .unittest) return error.UnitTestsCannotBeObjects;
  // Create the final binary name
  var result = str.init(trg.builder.A.allocator());
  const W = result.writer();
  try W.print("{s}", .{try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.sub, trg.trg})});
  if (opts.appendCpu) try W.print("{s}", .{@tagName(system.cpu)});
  switch (system.os) {
    .windows => try W.print("{s}", .{".obj"}),
    else     => try W.print("{s}", .{".o"}),
  } //:: switch (system.os)
  return try result.toOwnedSlice();
}

