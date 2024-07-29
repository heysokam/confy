//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
pub const Confy = @This();
const std = @import("std");
const Cfg = @import("./cfg.zig");

A    :std.heap.ArenaAllocator,
cfg  :Cfg,

pub fn init() !Confy {
  return Confy{
    .A   = std.heap.ArenaAllocator.init(std.heap.page_allocator),
    .cfg = Cfg{},
  };
}

pub fn term(confy :*Confy) void {
  confy.A.deinit();
}
