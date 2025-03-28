//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Language Management tools
//__________________________________________|
pub const language = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd   = @import("../../lib/zstd.zig");
const Lang   = zstd.Lang;
const System = zstd.System;
// @deps confy
const CodeList = @import("../code.zig");
const BuildTrg = @import("../target.zig").BuildTrg;

const LangPriority = [_]Lang{ .Cpp, .Zig, .C, .M, .Nim, .Asm, .Unknown };

const fromExt  = Lang.fromExt;
const fromFile = Lang.fromFile;
/// @descr Returns the preferred language of the {@arg src} CodeList, based on the extension priorities for each lang.
/// @note List of files that contain C++ code will be assumed to be targeting a C++ compiler, even if they combine C code in them.
/// @note List of files that contain Zig code will be assumed to be targeting a Zig compiler, even if they combine C code in them.
pub fn get (src :CodeList) Lang {
  var langs = std.EnumSet(Lang).initEmpty();
  for (src.files.items) | file | langs.insert(language.fromFile(file));
  if (langs.count() == 1) {
    var iter = langs.iterator();
    return iter.next().?;
  }
  for (LangPriority) |L| if (langs.contains(L)) return L;
  return Lang.Unknown;
}

// TODO:
// proc findExt *(file :DirFile) :string=
//   ## @descr
//   ##  Finds the extension of a file that is sent without it.
//   ##  Walks the file's dir, and matches all entries found against the full path of the given input file.
//   ## @raises IOError if the file does have an extension already.
//   if file.file.string.splitFile.ext != "": raise newException(IOError, &"Tried to find the extension of a file that already has one.\n  {file.dir/file.file}")
//   let filepath = file.dir/file.file
//   for found in file.dir.string.walkDir:
//     if found.kind == pcDir: continue
//     if filepath.string in found.path: return found.path.splitFile.ext
//   raise newException(IOError, &"Failed to find the extension of file:\n  {file.dir/file.file}")

