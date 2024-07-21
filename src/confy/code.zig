//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Describes the metadata and tools to manage a list of source code files.
//___________________________________________________________________________|
pub const CodeList = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const seq  = zstd.seq;
const cstr = zstd.cstr;
const cstr_List = zstd.cstr_List;

files :Data,
const Data = seq(cstr);

/// @descr Creates a new empty CodeList object, and initializes its memory
pub fn create (A :std.mem.Allocator) CodeList { return CodeList{.files= Data.init(A)}; }
/// @descr Frees all resources owned by the object.
pub fn destroy (L :*CodeList) void { L.files.deinit(); }
/// @descr Adds all files of {@arg B} to the list of files of {@arg A}. Allocates more memory as necessary.
pub fn add (A :*CodeList, B :CodeList) !void { try A.files.appendSlice(B.files.items); }
/// @descr Adds the {@arg file} to the list of files of {@arg L}. Allocates more memory as necessary.
pub fn addFile (L :*CodeList, file :cstr) !void { try L.files.append(file); }
/// @descr Adds the entire {@arg list} to the list of files of {@arg L}. Allocates more memory as necessary.
pub fn addList (L :*CodeList, files :cstr_List) !void { try L.files.appendSlice(files); }


const AddFolderOptions = struct {
  recursive  :bool= false,
  extension  :cstr= ".c",
  // access_sub_paths :bool= true,
  // no_follow        :bool= false,
};

/// @descr
///  Creates a list of all files stored in {@arg dir}, using the given {@arg args} options, and adds them to the list of files of {@arg L}
///  Allocates more memory as necessary.
pub fn addFolder2 (L :*CodeList, dir :cstr, args:AddFolderOptions) !void {
  var D = try std.fs.cwd().openDir(dir, std.fs.Dir.OpenDirOptions{
    .access_sub_paths = true,   // (default: true)
    .iterate          = true,   // (default: false)
    .no_follow        = false,  // (default: false)
  });
  defer D.close();
  if (args.recursive) {
    var walker = try D.walk(L.files.allocator);
    while (try walker.next()) | path | {
      if (path.kind != .file) continue;
      if (!std.mem.endsWith(u8, path.basename, args.extension)) continue;
      try L.addFile(try std.fs.path.join(L.files.allocator, &.{dir, path.path}));
    }
  } else {
    var it = D.iterate();
    while (try it.next()) | path | {
      if (path.kind != .file) continue;
      if (!std.mem.endsWith(u8, path.name, args.extension)) continue;
      try L.addFile(try std.fs.path.join(L.files.allocator, &.{dir, path.name}));
    }
  }
}

/// @descr
///  Creates a list of all files stored in {@arg dir}, using the default options, and adds them to the list of files of {@arg L}
///  Allocates more memory as necessary.
pub fn addFolder (L :*CodeList, dir :cstr) !void {
  try L.addFolder2(dir, CodeList.AddFolderOptions{});
}

