//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Describes the metadata and tools to create a confy Build Target.
//____________________________________________________________________|
const BuildTrg = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd    = @import("../lib/zstd.zig");
const cstr_List = zstd.cstr_List;
const cstr    = zstd.cstr;
const seq     = zstd.seq;
const str     = zstd.str;
const Version = zstd.Version;
const echo    = zstd.echo;
const prnt    = zstd.prnt;
const Lang    = zstd.Lang;
const System  = zstd.System;
// @deps confy
const Cfg        = @import("./cfg.zig");
const Submodule  = @import("./submodule.zig");
const Submodules = Submodule.List;
const Confy      = @import("./core.zig");
const CodeList   = @import("./code.zig");
const FlagList   = @import("./flags.zig");

pub const Kind = enum { program, static, lib, unittest };
const LangPriority = [_]Lang{ .Cpp, .Zig, .C, .M, .Nim, .Asm, .Unknown };


kind     :Kind,
cfg      :Cfg,
builder  :*Confy,

trg      :cstr,
src      :CodeList,
flags    :?FlagList= null,
sub      :cstr,
deps     :Submodules,
version  :Version= zstd.version(0,0,0),
// system   :std.Build.ResolvedTarget= undefined,
// optim    :std.builtin.OptimizeMode= undefined,
// priv     :BuildTrg.Private= undefined,

/// @description Forces the target to be built with the given {@link Lang} when specified. Will search by file extensions otherwise.
lang     :Lang= Lang.None,


//____________________________________
/// @section Language Management tools
//____________________________
const language = struct {
  const fromExt  = Lang.fromExt;
  const fromFile = Lang.fromFile;
  /// @descr Returns the preferred language of the {@arg src} CodeList, based on the extension priorities for each lang.
  /// @note List of files that contain C++ code will be assumed to be targeting a C++ compiler, even if they combine C code in them.
  /// @note List of files that contain Zig code will be assumed to be targeting a Zig compiler, even if they combine C code in them.
  fn get (src :CodeList) Lang {
    var langs = std.EnumSet(Lang).initEmpty();
    for (src.files.items) | file | langs.insert(BuildTrg.language.fromFile(file));
    if (langs.count() == 1) {
      var it = langs.iterator(); return it.next().?;
    } else {
      for (LangPriority) |L| {
        if (langs.contains(L)) return L;
      }
    }
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
};



//____________________________________
// @section Build Target Management tools
//____________________________
// BuildTrg Creation Arguments: Flags
const Flags_args = struct {
  cc  :cstr_List= &.{},
  ld  :cstr_List= &.{},
};
// BuildTrg Creation Arguments
const BuildTrg_args = struct {
  trg     : cstr,
  src     : ?cstr_List  = null,
  flags   : ?Flags_args = null,
  entry   : ?cstr       = null,
  cfg     : ?Cfg        = null,
  sub     : cstr        = "",
  deps    : ?[]const Submodule= null,
  version : cstr        = "0.0.0",
  lang    : ?Lang       = null,
};

//_____________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build the given binary {@arg kind}.
pub fn new (
    kind  : BuildTrg.Kind,
    args  : BuildTrg_args,
    confy : *Confy,
  ) !BuildTrg {
  var result = BuildTrg{
    .builder = confy,
    .kind    = kind,
    .trg     = args.trg,
    .cfg     = args.cfg orelse confy.cfg,
    .sub     = args.sub,
    .version = Version.parse(args.version) catch zstd.version(0,0,0),
    .src     = undefined,
    .deps    = undefined,
  };
  result.src   = CodeList.create(result.builder.A.allocator());
  result.deps  = Submodules.init(result.builder.A.allocator());
  result.flags = FlagList.create.empty(result.builder.A.allocator());
  if (args.entry != null) { try result.src.addFile(args.entry.?); }
  if (args.src   != null) { try result.src.addList(args.src.?); }
  if (args.deps  != null) { for (args.deps.?) | dep  | { try result.deps.append(dep); } }
  if (args.flags != null) {
    try result.flags.?.addCCList(args.flags.?.cc);
    try result.flags.?.addLDList(args.flags.?.ld);
  }
  result.lang = args.lang orelse BuildTrg.language.get(result.src);
  return result;
}
//_____________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build a Program.
pub fn Program   (args :BuildTrg_args, confy :*Confy) !BuildTrg { return BuildTrg.new(BuildTrg.Kind.program, args, confy); }
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build a Shared/Dynamic Library.
pub fn SharedLib (args :BuildTrg_args, confy :*Confy) !BuildTrg { return BuildTrg.new(BuildTrg.Kind.lib, args, confy); }
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build a Static Library.
pub fn StaticLib (args :BuildTrg_args, confy :*Confy) !BuildTrg { return BuildTrg.new(BuildTrg.Kind.static, args, confy); }
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to run a set of UnitTests.
pub fn UnitTest  (args :BuildTrg_args, confy :*Confy) !BuildTrg { return BuildTrg.new(BuildTrg.Kind.unittest, args, confy); }

//_____________________________________
/// @descr Adds the given {@arg L} CodeList of source code files to the {@arg trg}
pub fn add (trg :*BuildTrg, L :CodeList) !void {
  try trg.src.add(L);
  if (trg.lang == .Unknown) trg.lang = BuildTrg.language.get(trg.src);
}
//_____________________________________
/// @descr Adds the given {@arg L} FlagList of compiler flags to the {@arg trg}
pub fn set (trg :*BuildTrg, L :FlagList) !void {
  try trg.flags.?.add(L);
}


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
  /// @descr Always add the -target triple to the compilation command, even when not cross-compiling.
  explicitSystem  :bool=  false,
};

fn getBin (trg :*const BuildTrg, system :System, opts:BuildOptions) !cstr {
  // Simple case: early return for unittests
  if (trg.kind == .unittest) return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, "test"});
  // Create the final binary name
  var result = str.init(trg.builder.A.allocator());
  const W = result.writer();
  try W.print("{s}", .{try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.sub, trg.trg})});
  if (opts.appendCpu) try W.print("{s}", .{@tagName(system.cpu)});
  switch (trg.kind) {
    .program => try W.print("{s}", .{system.os.exeFileExt(system.cpu)}),
    .lib     => try W.print("{s}", .{system.os.dynamicLibSuffix()}),
    .static  => try W.print("{s}", .{system.os.staticLibSuffix(system.abi)}),
    else     => unreachable,
    } //:: switch (trg.kind)
  return try result.toOwnedSlice();
}

const zig = struct {
  //_____________________________________
  fn getCC (trg :*const BuildTrg) !cstr {
    return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.zig, "zig"});
  }
  fn getCacheDir (trg :*const BuildTrg) !cstr {
    return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.cache, "zig"});
  }
  fn getEmitBin (trg :*const BuildTrg, system :System, opts:BuildOptions) !cstr {
    return try std.fmt.allocPrint(trg.builder.A.allocator(), "-femit-bin={s}", .{try trg.getBin(system, opts)});
  }
  //_____________________________________
  /// @descr Orders confy to build the resulting binary for this Zig BuildTrg.
  fn buildFor (trg :*const BuildTrg, system :System, opts:BuildOptions) !void {
    var cc = zstd.shell.Cmd.create(trg.builder.A.allocator());
    defer cc.destroy();

    // Create the compilation command
    try cc.add(try zig.getCC(trg));
    switch (trg.kind) {
     .program     => try cc.add("build-exe"),
     .lib,.static => try cc.add("build-lib"),
     .unittest    => try cc.add("test"),
    }

    // Add the cache folder args
    const cache = try zig.getCacheDir(trg);
    try cc.addList(&.{"--cache-dir", cache, "--global-cache-dir", cache});
    // Add the cross-compilation target when needed
    if (system.cross() or opts.explicitSystem) {
      const target = try system.zigTriple(trg.builder.A.allocator());
      try cc.addList(&.{"-target", target});
      // FIX: target string will leak. How to defer dealloc from inside the if?
    }
    // Add the binary output
    try cc.add(try zig.getEmitBin(trg, system, opts));
    // Add the flags
    try cc.addList(trg.flags.?.cc.items);
    try cc.addList(trg.flags.?.ld.items);
    // Add the code
    try cc.addList(trg.src.files.items);

    // Report to CLI and build
    const bin = try trg.getBin(system, opts);
    defer trg.builder.A.allocator().free(bin);
    prnt("{s} Building Zig target binary: {s} ...\n", .{trg.cfg.prefix, bin});
    if (trg.cfg.verbose) prnt("  {s}\n", .{try std.mem.join(trg.builder.A.allocator(), " ", cc.parts.items)});
    prnt("{s} Done Building.\n", .{trg.cfg.prefix});
    try cc.run();
  }
};

const C = struct {
  //_____________________________________
  /// @descr Orders confy to build the resulting binary for this C BuildTrg.
  fn buildFor (trg :*const BuildTrg, system :System, opts:BuildOptions) !void {
    var cc = zstd.shell.Cmd.create(trg.builder.A.allocator());
    defer cc.destroy();
    try cc.add(try zig.getCC(trg));
    switch(trg.lang) {
      .C   => try cc.add("cc"),  // zig cc   for C code
      .Cpp => try cc.add("c++"), // zig c++  for Cpp code
      else => {},
    }
    switch (trg.kind) {
     .program     => {}, //try cc.add("build-exe"),
     .lib,        => try cc.add("-shared"),
     .static      => {}, //try cc.add("build-lib"),
     .unittest    => {}, //try cc.add("test"),
    }

    // Add the cross-compilation target when needed
    if (system.cross() or opts.explicitSystem) {
      const target = try system.zigTriple(trg.builder.A.allocator());
      try cc.addList(&.{"-target", target});
      // FIX: target string will leak. How to defer dealloc from inside the if?
    }

    // Add the code and flags
    try cc.addList(trg.src.files.items);
    try cc.addList(trg.flags.?.cc.items);
    try cc.addList(trg.flags.?.ld.items);

    // Add the target binary that will be output
    const bin = try trg.getBin(system, opts);
    defer trg.builder.A.allocator().free(bin);
    try cc.addList(&.{"-o", bin});

    // Report to CLI and run the command
    prnt("{s} Building C target binary: {s} ...\n", .{trg.cfg.prefix, bin});
    if (trg.cfg.verbose) prnt("  {s}\n", .{try std.mem.join(trg.builder.A.allocator(), " ", cc.parts.items)});
    try cc.run();
    prnt("{s} Done Building.\n", .{trg.cfg.prefix});
  }
};

//_____________________________________
/// @descr Orders confy to build the resulting binary of {@arg trg} for the given {@arg system}
pub fn buildFor (trg :*const BuildTrg, system :System, opts:BuildOptions) !void {
  // @note Sends the control flow of the builder into the relevant function to build the resulting binary for this BuildTrg.
  switch (trg.lang) {
    .Zig      => try zig.buildFor(trg, system, opts),
    .C, .Cpp, => try C.buildFor(trg, system, opts),
    .Nim      => std.debug.panic("Support for compiling Nim has not been reimplemented yet.\n", .{}),
    else => std.debug.panic("Found a language that has no implemented build command:  {s}\n", .{@tagName(trg.lang)}),
  }
}
//_____________________________________
/// @descr Orders confy to build the resulting binary of {@arg trg} for all of the {@arg systems}
pub fn buildForAll (trg :*const BuildTrg, systems :[]const System, opts:BuildOptions) !void {
  for (systems) | system | { try trg.buildFor(system, opts); }
}
//_____________________________________
/// @descr Orders confy to build the resulting binary of {@arg trg} for the host system, using the default {@link BuildOptions}.
pub fn build (trg :*const BuildTrg) !void { try trg.buildFor(System.host(), .{}); }

//_____________________________________
/// @descr Orders confy to run the resulting binary of {@arg trg}.
pub fn run (trg :*const BuildTrg) !void {
  prnt("{s} Running {s} ...\n", .{trg.cfg.prefix, try trg.getBin(System.host(), .{})});
  try zstd.shell.run(&.{try trg.getBin(System.host(), .{})}, trg.builder.A.allocator());
}

// TODO: What was this reference code for?
//fn getBin (trg :*const BuildTrg, system :System, opts:BuildOptions) !cstr {

