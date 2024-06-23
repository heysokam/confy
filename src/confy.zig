//:_____________________________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:_____________________________________________________________________
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("./lib/zstd.zig");

//______________________________________
// @section zstd Ergonomics
//____________________________
const cstr      = zstd.T.cstr;
const cstr_List = zstd.T.cstr_List;
const echo      = zstd.echo;


pub const Submodule = struct {
  name :cstr,
  url  :cstr,
  src  :cstr= DefaultSrcSubdir,

  // Submodule Configuration Defaults
  const DefaultSrcSubdir = "src";

  pub fn new(args :struct{
    name : cstr,
    url  : cstr,
    src  : cstr = DefaultSrcSubdir,
  }) Submodule {
    return Submodule{
      .name = args.name,
      .url  = args.url,
      .src  = args.src,
    };
  }

  pub fn clone(S :*const Submodule) void {
    std.debug.print("...............\n", .{});
    std.debug.print("Submodule.clone\n", .{});
    std.debug.print("{s}\n", .{S.name});
    std.debug.print("{s}\n", .{S.url});
    std.debug.print("{s}\n", .{S.src});
    std.debug.print("...............\n", .{});
  }
};

pub const Submodules = []const Submodule;

pub const BuildKind = enum {
  program, lib, static,
  fn from(comptime T: type) @This() {
    return switch(T) {
      Program   => BuildKind.program,
      SharedLib => BuildKind.lib,
      StaticLib => BuildKind.static,
      else      => unreachable,
    };
  }
};

fn BuildTrg(comptime T: type) type {
  return struct {
    kind  :BuildKind,
    cfg   :cfg,
    src   :cstr_List,
    sub   :cstr,
    trg   :cstr,
    deps  :Submodules,

    pub fn new(args :struct {
      src  : cstr_List,
      trg  : cstr,
      deps : Submodules = &.{},
      cfg  : cfg        = cfg{},
      sub  : cstr       = "",
    }) @This() {
      const result = @This(){
        .kind = BuildKind.from(T),
        .cfg  = args.cfg,
        .src  = args.src,
        .sub  = args.sub,
        .trg  = args.trg,
        .deps = args.deps,
        };
      return result;
    }

    pub fn build(trg :*const @This()) void {
      std.debug.print("BuildTrg.build {}\n", .{trg});
      trg.deps[0].clone();
    }
  };
}

pub const Program   = struct { pub usingnamespace BuildTrg(Program); };
pub const SharedLib = struct { pub usingnamespace BuildTrg(SharedLib); };
pub const StaticLib = struct { pub usingnamespace BuildTrg(StaticLib); };

pub const cfg = struct {
  verbose :bool= false,
  quiet   :bool= false,
  dir     :ProjectDirs= ProjectDirs{},

  const ProjectDirs = struct {
    root  :cstr= ".",
    bin   :cstr= "bin",
    src   :cstr= "src",
    lib   :cstr= "lib",
    cache :cstr= "cache",
    zig   :cstr= ".zig",
    min   :cstr= ".M",
    nim   :cstr= ".nim",
  };

  pub fn init(B :*std.Build) cfg {
    const result :cfg= cfg{};
    _=B;
    return result;
  }
};

