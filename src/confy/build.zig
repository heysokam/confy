//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Tools required to connect confy with the default Zig buildsystem.
//! @note
//!  Very minimal functionality. Not too useful in its current state, but does its job.
//!  The preferred way of running confy is running the `build.zig.sh` script instead.
//______________________________________________________________________________________|
pub const buildzig = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;
// @deps confy
const cfg = @import("./cfg.zig");


const RunOptions = struct {
  builder  :Builder=  Builder{},
  const Builder = struct {
    src  :cstr=  cfg.default.dir.src++cfg.default.builder++".zig",
    trg  :cstr=  cfg.default.builder,
  };
};


//________________________________________________
/// @descr Compiles+Runs the Confy Builder of the project with the default options.
/// @note Used only to connect to the standard `zig build` calls
pub fn run  (B:*std.Build) void { buildzig.run2(B, .{}); }
//________________________________________________
/// @descr Compiles+Runs the Confy Builder of the project with the spectified list of {@arg opt}.
/// @note Used only to connect to the standard `zig build` calls
pub fn run2 (B:*std.Build, opt :buildzig.RunOptions) void {
  const optim   = B.standardOptimizeOption(.{});
  const builder = B.addExecutable(.{
    .name             = opt.builder.trg,
    .root_source_file = B.path(opt.builder.src),
    .target           = B.host,
    .optimize         = optim,
    });
  B.installArtifact(builder);
  const builder_run = B.addRunArtifact(builder);
  const runner = B.step("run", "Build/Run the Confy Builder");
  runner.dependOn(&builder_run.step);
}

