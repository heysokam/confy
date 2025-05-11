//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
pub const C = @This();
// @deps std
const std = @import("std");
// @deps confy
const zig          = @import("./zig.zig");
const BuildTrg     = @import("../target.zig");
const BuildOptions = BuildTrg.BuildOptions;


//_____________________________________
/// @descr Orders confy to build a StaticLibrary for this C BuildTrg.
fn buildStaticLib (trg :*const BuildTrg, system :System, opts:BuildOptions) !void {
  // Find the filename of the target binary
  const bin = try trg.getBin(system, opts);
  defer trg.builder.A.allocator().free(bin);
  // Find the filename of the intermediate object
  const obj = try trg.getObj(system, opts);
  defer trg.builder.A.allocator().free(bin);

  // Create the compiler command
  var cc = zstd.shell.Cmd.create(trg.builder.A.allocator());
  defer cc.destroy();
  try cc.add(try zig.getCC(trg));
  switch(trg.lang) {
    .C   => try cc.add("cc"),  // zig cc   for C code
    .Cpp => try cc.add("c++"), // zig c++  for Cpp code
    else => {},
  }
  // Add the extra/custom commands requested by the user
  for (trg.args) |arg| try cc.add(arg);
  // Add the code and flags
  try cc.add("-c");  // Order to build an intermediate object
  try cc.addList(trg.src.files.items);
  try cc.addList(trg.flags.?.cc.items);
  try cc.addList(trg.flags.?.ld.items);
  // Add the cross-compilation target when needed
  if (system.cross() or opts.explicitSystem) {
    const target = try system.zigTriple(trg.builder.A.allocator());
    try cc.addList(&.{"-target", target});
    // FIX: target string will leak. How to defer dealloc from inside the if?
  }
  // Add the target binary to the ZigCC command
  try cc.addList(&.{"-o",  obj});

  // Create the archiver command
  var ar = zstd.shell.Cmd.create(trg.builder.A.allocator());
  defer ar.destroy();
  try ar.add(try zig.getCC(trg));
  try ar.addList(&.{"ar", "-rc"});
  // Add the target binary to the ZigAR command
  try ar.addList(&.{bin, obj});

  // Report to CLI and run the commands
  prnt("{s} Building C intermediate object: {s} ...\n", .{trg.cfg.prefix, obj});
  if (trg.cfg.verbose) prnt("  {s}\n", .{try std.mem.join(trg.builder.A.allocator(), " ", cc.parts.items)});
  try cc.run();
  prnt("{s} Building C StaticLibrary: {s} ...\n", .{trg.cfg.prefix, bin});
  if (trg.cfg.verbose) prnt("  {s}\n", .{try std.mem.join(trg.builder.A.allocator(), " ", ar.parts.items)});
  try ar.run();
  prnt("{s} Done Building.\n", .{trg.cfg.prefix});
} //:: C.buildStaticLib

