//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Describes the metadata and tools to create a confy Build Target.
//____________________________________________________________________|
const BuildTrg = @This();
// @deps zstd
const zstd    = @import("../lib/zstd.zig");
const cstr    = zstd.cstr;
const cstr_List = zstd.cstr_List;
const seq     = zstd.seq;
const Version = zstd.Version;
// @deps confy
const cfg        = @import("./cfg.zig");
const Submodule  = @import("./submodule.zig");
const Submodules = Submodule.List;


kind     :Kind,
cfg      :cfg,
src      :seq(cstr),
sub      :cstr,
trg      :cstr,
deps     :Submodules,
version  :Version= zstd.version(0,0,0),
// system   :std.Build.ResolvedTarget= undefined,
// optim    :std.builtin.OptimizeMode= undefined,
// priv     :BuildTrg.Private= undefined,

pub const Kind = enum { program, static, lib, unittest };

//..........
// TODO:  ..
//..........

// @descr Orders confy to build the resulting binaries for this BuildTrg.
// pub fn build(trg :*const @This()) void {
//   std.debug.print("BuildTrg.build {any}\n", .{trg});
//   trg.deps[0].clone();
// }


//______________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build the given binary {@arg kind}.
pub fn new(
    kind : BuildTrg.Kind,
    src  : cstr_List,
    trg  : cstr,
    args : struct{
    cfg  : cfg  = cfg{},
    sub  : cstr = "",
    deps : []const Submodule = &.{},
  }) BuildTrg {
  var result = BuildTrg{
    .kind    = kind,
    .cfg     = args.cfg,
    .sub     = args.sub,
    .trg     = trg,
    .deps    = args.deps,
    .version = args.version,
  };
  for (src) | file | { result.src.append(file); }
  return result;
}

//______________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build a Program.
pub fn Program (
    src  : cstr_List,
    trg  : cstr,
    args : struct{
    cfg  : cfg  = cfg{},
    sub  : cstr = "",
    deps : []const Submodule = &.{},
  }) BuildTrg {
  return BuildTrg.new(BuildTrg.Kind.program, src, trg, args);
}

//______________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build a Shared/Dynamic Library.
pub fn SharedLib (
    src  : cstr_List,
    trg  : cstr,
    args : struct{
    cfg  : cfg  = cfg{},
    sub  : cstr = "",
    deps : []const Submodule = &.{},
  }) BuildTrg {
  return BuildTrg.new(BuildTrg.Kind.lib, src, trg, args);
}

//______________________________________
/// @descr Creates a new {@link BuildTrg} object that can be used by confy to build a Static Library.
pub fn StaticLib (
    src  : cstr_List,
    trg  : cstr,
    args : struct{
    cfg  : cfg  = cfg{},
    sub  : cstr = "",
    deps : []const Submodule = &.{},
  }) BuildTrg {
  return BuildTrg.new(BuildTrg.Kind.static, src, trg, args);
}

