//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
pub const nim = @This();
// @deps std
const std = @import("std");
// @deps zdk
const zstd   = @import("../../lib/zstd.zig");
const cstr   = zstd.cstr;
const System = zstd.System;
const prnt   = zstd.prnt;
// @deps confy
const BuildTrg     = @import("../target.zig");
const BuildOptions = BuildTrg.BuildOptions;

// @reference
//  clang.cppCompiler = "zigcpp"
//  clang.cppXsupport = "-std=C++20"
//  nim c --cc:clang --clang.exe="zigcc" --clang.linkerexe="zigcc" --opt:speed hello.nim
// const CCTempl = "{nim} {nimBackend} -d:zig --cc:clang --clang.exe=\"{zigcc}\" --clang.linkerexe=\"{zigcc}\" --clang.cppCompiler=\"{zigcpp}\" --clang.cppXsupport=\"-std=c++20\"";
//_____________________________________
fn getCC       (trg :*const BuildTrg) !cstr { return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.nim, "/bin/nim"});  }
fn getZigCC    (trg :*const BuildTrg) !cstr { return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.zig, "zigcc"});  }
fn getZigCPP   (trg :*const BuildTrg) !cstr { return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.zig, "zigcpp"});  }
fn getCacheDir (trg :*const BuildTrg) !cstr { return try std.fs.path.join(trg.builder.A.allocator(), &.{trg.cfg.dir.bin, trg.cfg.dir.cache, "nim"});  }

//_____________________________________
/// @descr Orders confy to build the resulting binary for this C BuildTrg.
pub fn buildFor (trg :*const BuildTrg, S :System, in:BuildOptions) !void {
  const A = trg.builder.A.allocator();
  var cc = zstd.shell.Cmd.create(trg.builder.A.allocator());
  defer cc.destroy();

  // Create the base compilation command
  const nimBin = try nim.getCC(trg);
  defer A.free(nimBin);
  try cc.add(nimBin);
  try cc.add("c");
  // Add ZigCC support
  try cc.add("-d:zig");
  try cc.add("--cc:clang");
  const zigcc  = try nim.getZigCC(trg);  defer A.free(zigcc);
  const zigcpp = try nim.getZigCPP(trg); defer A.free(zigcpp);
  try cc.add(try std.fmt.allocPrint(A, "--clang.exe={s}", .{zigcc}));
  try cc.add(try std.fmt.allocPrint(A, "--clang.linkerexe={s}", .{zigcc}));
  try cc.add(try std.fmt.allocPrint(A, "--clang.cppCompiler={s}", .{zigcpp}));
  try cc.add("--clang.cppXsupport=\"-std=c++20\"");

  // Add the NimCC specific options
  if (trg.cfg.force) { try cc.add("-f"); }
  if (trg.cfg.verbose) { try cc.add("--verbosity:3"); }
  else if (trg.cfg.quiet) { try cc.add("--hints:off");   }
  // Add the cache folder args
  const cacheOpt = try std.fmt.allocPrint(A, "--nimcache:{s}", .{try nim.getCacheDir(trg)});
  defer A.free(cacheOpt);
  try cc.add(cacheOpt);

  // Output a Library when relevant
  switch (trg.kind) {
   .lib    => try cc.add("--app:lib"),
   .static => try cc.add("--app:staticlib"),
   .program,.unittest => {},
  }
  // Add the cross-compilation target when needed
  if (S.cross() or in.explicitSystem) {
    // FIX: These strings will leak. How to defer dealloc from inside an if?
    try cc.add(try std.fmt.allocPrint(A, "--os:{s}", .{try S.nimOS(A)}));
    try cc.add(try std.fmt.allocPrint(A, "--cpu:{s}", .{try S.nimCPU(A)}));
    try cc.add(try std.fmt.allocPrint(A, "--passC:\"-target {s}\"", .{try S.zigTriple(A)}));
    try cc.add(try std.fmt.allocPrint(A, "--passL:\"-target {s}\"", .{try S.zigTriple(A)}));
  }
  // Add the binary output
  const outDir = try std.fs.path.join(A, &.{trg.cfg.dir.bin, trg.sub});
  defer A.free(outDir);
  try cc.add(try std.fmt.allocPrint(A, "--out:{s}", .{trg.trg}));
  try cc.add(try std.fmt.allocPrint(A, "--outdir:{s}", .{outDir}));
  // Add the flags
  if (trg.cfg.nim.unsafeFunctionPointers) try cc.add("--passC:-Wno-incompatible-function-pointer-types");
  // Add the extra/custom commands requested by the user
  for (trg.args) |arg| try cc.add(arg);

  // Add the Dependencies/Submodules
  for (trg.deps.items) |dep| try cc.add(try dep.toNim(trg.cfg.dir.lib, A));
  // Add the code
  try cc.add(trg.src.files.items[0]);

  // Report to CLI and run the command
  prnt("{s} Building Nim target binary: {s} ...\n", .{trg.cfg.prefix, trg.trg});
  if (trg.cfg.verbose) prnt("  {s}\n", .{try std.mem.join(trg.builder.A.allocator(), " ", cc.parts.items)});
  try cc.run();
  prnt("{s} Done Building.\n", .{trg.cfg.prefix});
} //:: BuildTrg.nim.buildFor

