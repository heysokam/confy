//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
pub const zig = @This();
// @deps std
const std = @import("std");
// @deps zdk
const zstd   = @import("../../lib/zstd.zig");
const cstr   = zstd.cstr;
const System = zstd.System;
const prnt   = zstd.prnt;
const echo   = zstd.echo;
// @deps confy
const BuildTrg     = @import("../target.zig");
const BuildOptions = BuildTrg.BuildOptions;
const Dependency   = @import("../dependency.zig");

fn getEmitBin (trg :*const BuildTrg, system :System, opts:BuildOptions) !cstr {
  return try std.fmt.allocPrint(trg.builder.A.allocator(), "-femit-bin={s}", .{try trg.getBin(system, opts)});
} //:: BuildTrg.zig.getEmitBin


//_____________________________________
/// @descr Orders confy to build the resulting binary for this Zig BuildTrg.
pub fn buildFor (trg :*const BuildTrg, system :System, opts:BuildOptions) !void {
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
  // Add the dependencies as Modules
  const modules = try zig.getModules(trg);
  const hasM = modules.items.len > 0;
  for (modules.items) |mod| try cc.add(mod.items);

  // Add the binary output
  try cc.add(try zig.getEmitBin(trg, system, opts));
  // Add the flags
  try cc.addList(trg.flags.?.cc.items);
  try cc.addList(trg.flags.?.ld.items);
  // Add the extra/custom commands requested by the user
  for (trg.args) |arg| try cc.add(arg);

  // Add the code  (skip the entry/root if there are modules defining it)
  if (hasM) try cc.addList(trg.src.files.items[1..])
  else try cc.addList(trg.src.files.items);

  try cc.add("-freference-trace");

  // Report to CLI and build
  const bin = try trg.getBin(system, opts);
  defer trg.builder.A.allocator().free(bin);
  prnt("{s} Building Zig target binary: {s} ...\n", .{trg.cfg.prefix, bin});
  if (trg.cfg.verbose) prnt("  {s}\n", .{try std.mem.join(trg.builder.A.allocator(), " ", cc.parts.items)});
  try cc.run();
  prnt("{s} Done Building.\n", .{trg.cfg.prefix});
} //:: BuildTrg.zig.buildFor

