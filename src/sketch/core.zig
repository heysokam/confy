//:_____________________________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:_____________________________________________________________________
//! @fileoverview
//!  Confy : Comfortable and Configurable Buildsystem
//!  @todo : Docs here
//_____________________________________________________|


//______________________________________
// @section Forward export confy to the user for ergonomics
//____________________________
pub usingnamespace @import("./src/confy.zig");


//______________________________________
/// @section confy: Private tools for self init and internal tasks
//____________________________
pub const P_ = struct {
  // @deps std
  const std = @import("std");
  // @deps zstd
  const zstd = @import("./src/lib/zstd.zig");
  const echo = zstd.echo;
  const confy = @import("./src/confy.zig");
  const cstr = zstd.T.cstr;

  pub fn _init(B :*std.Build) void {
    echo("Hello confy.P_._init");

    const cfy = confy.Program.new(.{
      .cfg  = confy.cfg.init(B),
      .src  = &.{"./entry.zig"},
      .trg  = "confy",
      .deps = &.{
        confy.Submodule.new(.{.name = "test", .url = "dummy://url"}),
        } // << deps
      }); // << confy.Program.new(.{ ... })
    cfy.build();
  }
  const dir :std.fs.Dir= undefined;
};

