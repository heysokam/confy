//:_______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:_______________________________________________________________________
//! @fileoverview Confy's Git Management tools
//______________________________________________|
const Git = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;


//______________________________________
/// @descr Describes metadata/information about a Git repository, and provides tool to manage it.
pub const Info = struct {
  baseURL :cstr= "https://github.com",
  owner   :cstr,
  repo    :cstr,

  //______________________________________
  const Templ = "{s}/{s}/{s}";
  /// @descr Provides the functionality required for {@link Git.Info} objects to work with default zig formatting functions.
  pub fn format (G :*const Git.Info, comptime _:[]const u8, _:std.fmt.FormatOptions, writer :anytype) !void {
    try writer.print(Git.Info.Templ, .{G.baseURL, G.owner, G.repo});
  }

  //______________________________________
  /// @descr Returns a formatted URL of the given {@arg G} {@link Git.Info} object.
  /// @note
  ///  Allocates a {@link cstr} owned by the caller.
  ///  Use the provided {@link Git.Info.format} function if you need/prefer to not allocate.
  pub fn URL (G :*const Git.Info, A :std.mem.Allocator) cstr {
    return std.fmt.allocPrint(A, "{s}", .{G});
  }
};

