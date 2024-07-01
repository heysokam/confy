//:_____________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
//:_____________________________________________________
//! @fileoverview                                      |
//!  Dummy connector for using `confy` as a module     |
//!  See ./src/confy.zig for documentation             |
//_____________________________________________________|
pub fn build(b: *@import("std").Build) void {
  _ = b.addModule("confy", .{
    .root_source_file = .{ .path = "src/confy.zig" },
    .target           = b.standardTargetOptions(.{}),
    .optimize         = b.standardOptimizeOption(.{}),
   });
}

//_____________________________________________________
// TODO: Remove
//       Early sketch-y buildsystem integration
//______________________________________
// const Build = @import("std").Build;
// const self = @import("confy.zig").P_;
// pub fn build(b :*Build) void { self._init(b); }
//_____________________________________________________

