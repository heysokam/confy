//:_____________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
//:_____________________________________________________
//! @fileoverview
//!  Confy : Comfortable and Configurable Buildsystem
//!  @todo : Docs here
//_____________________________________________________|
const Git = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;

pub const Info = struct {
  baseURL :cstr= "https://github.com/",
  owner   :cstr,
  repo    :cstr,

  pub fn URL(G :*Git.Info) cstr {
    const a = std.fmt.format();
    _ = a;
    std.debug.print("", .{});
    return  G.baseURL;
  }
};

