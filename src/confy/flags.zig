//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Describes the metadata and tools to manage a list of compilation flags.
//___________________________________________________________________________|
pub const FlagList = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const seq  = zstd.seq;
const cstr = zstd.cstr;
const cstr_List = zstd.cstr_List;


cc  :Data,
ld  :Data,
const Data = seq(cstr);

/// @descr Creates a new empty FlagList object, and initializes its memory
pub fn create (A :std.mem.Allocator) FlagList { return FlagList{.cc= Data.init(A), .ld= Data.init(A)}; }
/// @descr Frees all resources owned by the object.
pub fn destroy (L :*FlagList) void { L.cc.deinit(); L.ld.deinit(); }
/// @descr Adds all flags of {@arg B} to the list of files of {@arg A}. Allocates more memory as necessary.
pub fn add (A :*FlagList, B :FlagList) !void { try A.addCCList(B.cc.items); try A.addLDList(B.ld.items); }
/// @descr Adds the {@arg flag} to the list of CC flags of {@arg L}. Allocates more memory as necessary.
pub fn addCC (L :*FlagList, flag :cstr) !void { try L.cc.append(flag); }
/// @descr Adds the entire {@arg flags} list to the list of CC flags of {@arg L}. Allocates more memory as necessary.
pub fn addCCList (L :*FlagList, flags :cstr_List) !void { try L.cc.appendSlice(flags); }
/// @descr Adds the {@arg flag} to the list of LD flags of {@arg L}. Allocates more memory as necessary.
pub fn addLD (L :*FlagList, flag :cstr) !void { try L.cc.append(flag); }
/// @descr Adds the entire {@arg flags} list to the list of LD flags of {@arg L}. Allocates more memory as necessary.
pub fn addLDList (L :*FlagList, flags :cstr_List) !void { try L.cc.appendSlice(flags); }





//:::::::::::::::::::::::::::::::::::::::::::::::::::::
// TODO: Smart add flags to the list they belong to  ::
//:::::::::::::::::::::::::::::::::::::::::::::::::::::

const Kind = enum { CC, LD };
/// @todo
const Flags = std.StaticStringMap(FlagList.Kind).initComptime(.{
  // C Standards
  .{ "-std=c89", .CC },
  .{ "-std=c99", .CC },
  .{ "-std=c11", .CC },
  .{ "-std=c2x", .CC },
  .{ "-std=c23", .CC },
  // ...
});


/// @todo
/// @descr Smart adds the {@arg flag} to the list of flags of {@arg L}. Allocates more memory as necessary.
fn addFlag (L :*FlagList, flag :cstr) !void {
  try L.cc.append(flag);
}
/// @todo
/// @descr Smart adds the entire {@arg flags} list to the list of flags of {@arg L}. Allocates more memory as necessary.
fn addList (L :*FlagList, flags :cstr_List) !void {
  try L.cc.appendSlice(flags);
}

