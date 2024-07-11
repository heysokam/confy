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
const cstr    = zstd.cstr;
const cstr_List = zstd.cstr_List;
const seq     = zstd.seq;
const Version = zstd.Version;
const echo    = zstd.echo;
const prnt    = zstd.prnt;
// @deps confy
const cfg        = @import("./cfg.zig");
const Submodule  = @import("./submodule.zig");
const Submodules = Submodule.List;
const Confy      = @import("./core.zig");

kind     :Kind,
cfg      :cfg,
builder  :*Confy,

trg      :cstr,
src      :CodeList,
sub      :cstr,
deps     :Submodules,
version  :Version= zstd.version(0,0,0),
// system   :std.Build.ResolvedTarget= undefined,
// optim    :std.builtin.OptimizeMode= undefined,
// priv     :BuildTrg.Private= undefined,


const CodeList = seq(cstr);
pub const Kind = enum { program, static, lib, unittest };

const BuildTrg_args = struct {
  trg     : cstr,
  src     : ?cstr_List= null,
  entry   : ?cstr = null,
  cfg     : cfg   = cfg{},
  sub     : cstr  = "",
  deps    : ?[]const Submodule= null,
  version : cstr  = "0.0.0",
};

//_____________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build the given binary {@arg kind}.
pub fn new(
    kind  : BuildTrg.Kind,
    args  : BuildTrg_args,
    confy : *Confy,
  ) !BuildTrg {
  var result = BuildTrg{
    .builder = confy,
    .kind    = kind,
    .trg     = args.trg,
    .cfg     = args.cfg,
    .sub     = args.sub,
    .version = Version.parse(args.version) catch zstd.version(0,0,0),
    .src     = undefined,
    .deps    = undefined,
  };
  result.src  = CodeList.init(result.builder.A.allocator());
  result.deps = Submodules.init(result.builder.A.allocator());
  if (args.entry != null) try result.src.append(args.entry.?);
  if (args.src  != null) { for (args.src.?)  | file | { try result.src.append(file); } }
  if (args.deps != null) { for (args.deps.?) | dep  | { try result.deps.append(dep); } }
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
fn getZigBin (trg :*const BuildTrg) !cstr {
  return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.zig, "zig"});
}
fn getCacheDir (trg :*const BuildTrg) !cstr {
  return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.cache, "zig"});
}
fn getBin (trg :*const BuildTrg) !cstr {
  return switch(trg.kind) {
    .unittest => try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, "test"}),
    else      => try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.sub, trg.trg}),
    };
}
fn getEmitBin (trg :*const BuildTrg) !cstr {
  return try std.fmt.allocPrint(trg.builder.A.allocator(), "-femit-bin={s}", .{try trg.getBin()});
}

//_____________________________________
/// @descr Orders confy to build the resulting binary for this BuildTrg.
pub fn build (trg :*const BuildTrg) !void {
  // Create the compilation command
  var args = seq(cstr).init(trg.builder.A.allocator());
  try args.append(try trg.getZigBin());
  switch (trg.kind) {
   .program     => try args.append("build-exe"),
   .lib,.static => try args.append("build-lib"),
   .unittest    => try args.append("test"),
  }
  // Add the cache folder args
  const cache = try trg.getCacheDir();
  try args.appendSlice(&.{"--cache-dir", cache, "--global-cache-dir", cache});
  // Add the binary output
  try args.append(try trg.getEmitBin());
  // Add the code
  try args.appendSlice(trg.src.items);
  // Report to CLI and build
  echo("ᛝ confy: Building target binary ...");
  try zstd.shell.run(args.items, trg.builder.A.allocator());
  echo("ᛝ confy: Done Building.");
}

//_____________________________________
/// @descr Orders confy to run the resulting binary for this BuildTrg.
pub fn run (trg :*const BuildTrg) !void {
  echo("ᛝ confy: Running ...");
  try zstd.shell.run(&.{try trg.getBin()}, trg.builder.A.allocator());
}

