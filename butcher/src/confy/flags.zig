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
const Lang = zstd.Lang;

const BuildMode = enum { debug, release };

cc  :Data,
ld  :Data,
const Data = seq(cstr);

pub const create = struct {
  pub const default = struct {
    pub const C = struct {
      pub fn all (A :std.mem.Allocator) !FlagList {
        var result = FlagList.create.empty(A);
        try result.addCC(FlagList.default.C.CC.cstd);
        try result.addCCList(FlagList.default.C.CC.base);
        try result.addCCList(FlagList.default.C.CC.errors);
        try result.addCCList(FlagList.default.C.CC.others);
        return result;
      }
      pub fn strict (mode :BuildMode, A :std.mem.Allocator) !FlagList {
        return switch (mode) {
        .debug   => try FlagList.create.fromFlags(
                        FlagList.default.C.CC.strict.debug,
                        FlagList.default.C.LD.strict.debug, A),
        .release => try FlagList.create.fromFlags(
                        FlagList.default.C.CC.strict.release,
                        FlagList.default.C.LD.strict.release, A),
        };
      }
    };
    pub const Cpp = struct {
      pub fn all(A :std.mem.Allocator) !FlagList { _=A; }
    };
  };
  pub fn defaults (A :std.mem.Allocator, lang :Lang) !FlagList {
    switch (lang) {
      .C   => return try FlagList.create.default.C.all(A),
      // .Cpp => return try FlagList.create.default.Cpp.all(A),
      else => std.debug.panic("Error :: Tried to get the default flags for a language, but they have not been defined:  {s}", .{@tagName(lang)}),
    }
  }
  pub fn strict (A :std.mem.Allocator, lang :Lang) !FlagList {
    switch (lang) {
      .C   => return try FlagList.create.default.C.strict(A),
      else => std.debug.panic("{s}: Error :: Tried to get the strict flags for a language, but they have not been defined:  {s}", .{@tagName(lang)}),
    }
  }

};



pub const default = struct {
  pub const C = struct {
    pub const CC = struct {
      pub const cstd :cstr_List= "-std=c11";
      pub const base :cstr_List= &.{
        "-Wall",
        "-Wpedantic", "-pedantic",  // Enforce ISO C standard
      }; //:: base
      pub const extra :cstr_List= &.{
        "-Wextra",
        "-Wdouble-promotion",  // Warn when a float is promoted to double
      }; //:: extra
      pub const errors :cstr_List= &.{
        "-Werror",
        "-pedantic-errors",
      }; //:: errors
      pub const others :cstr_List= &.{
        "-Wmissing-prototypes",
        "-Wmisleading-indentation",
        "-Wold-style-definition",
        "-Wconversion",
        "-Wshadow",
        "-Winit-self",
        "-Wfloat-equal",
        "-Wstrict-prototypes",
        "-Wduplicated-cond",
        "-fdiagnostics-minimum-margin-width=5",
        "-Wcast-align=strict",
        "-Wformat-overflow=2",
        "-Wformat-truncation=2",
        "-fdiagnostics-format=text",
        //"-Wwrite-strings",
      }; //:: others
      pub const optim = struct {
        pub const arch = struct {
          pub const x86_64 :cstr_List= &.{
            "-m64", // 64bit types
            "-march=x86_64",
            "-mtune=x86_64",
          }; //:: x86_64
        }; //:: arch
        const release :cstr_List= &.{
          "-O2",
        }; //:: release
        const debug :cstr_List= &.{
          // Debugger Flags
          "-Og",
          "-ggdb",
        }; //:: debug
      };
      ///_____________________________________
      /// @descr Declares the sets of Flags that will turn the ZigCC.Clang compiler into Strict mode
      pub const strict = struct {
        //_____________________________________
        /// @descr Flags to add to the strict list in all cases
        pub const base :cstr_List= &.{
          "-std=c2x",
          "-Weverything",
          "-Werror",
          "-pedantic",
          "-pedantic-errors",
          // Filter Unnecessary flags out of -Weverything
          "-Wno-declaration-after-statement", // Explicitly allow asignment on definition. Useless warning for >= C99
          "-Wno-ignored-qualifiers",          // Explicitly allow const return type qualifiers. Returning a const type spams this warning
          // Ignore C++ flags. We build C
          "-Wno-c++-compat",
          "-Wno-c++0x-compat",                   "-Wno-c++0x-extensions",                         "-Wno-c++0x-narrowing",
          "-Wno-c++11-compat",                   "-Wno-c++11-compat-deprecated-writable-strings", "-Wno-c++11-compat-pedantic",       "-Wno-c++11-compat-reserved-user-defined-literal",
          "-Wno-c++11-extensions",               "-Wno-c++11-extra-semi",                         "-Wno-c++11-inline-namespace",      "-Wno-c++11-long-long",                            "-Wno-c++11-narrowing",
          "-Wno-c++14-attribute-extensions",     "-Wno-c++14-binary-literal",                     "-Wno-c++14-compat",                "-Wno-c++14-compat-pedantic",                      "-Wno-c++14-extensions",
          "-Wno-c++17-attribute-extensions",     "-Wno-c++17-compat",                             "-Wno-c++17-compat-mangling",       "-Wno-c++17-compat-pedantic",                      "-Wno-c++17-extensions",
          "-Wno-c++1y-extensions",               "-Wno-c++1z-compat",                             "-Wno-c++1z-compat-mangling",       "-Wno-c++1z-extensions",
          "-Wno-c++20-attribute-extensions",     "-Wno-c++20-compat",                             "-Wno-c++20-compat-pedantic",       "-Wno-c++20-designator",                           "-Wno-c++20-extensions",
          "-Wno-c++2a-compat",                   "-Wno-c++2a-compat-pedantic",                    "-Wno-c++2a-extensions",            "-Wno-c++2b-extensions",
          "-Wno-c++98-c++11-c++14-c++17-compat", "-Wno-c++98-c++11-c++14-c++17-compat-pedantic",  "-Wno-c++98-c++11-c++14-compat",    "-Wno-c++98-c++11-c++14-compat-pedantic",
          "-Wno-c++98-c++11-compat",             "-Wno-c++98-c++11-compat-binary-literal",        "-Wno-c++98-c++11-compat-pedantic",
          "-Wno-c++98-compat",                   "-Wno-c++98-compat-bind-to-temporary-copy",      "-Wno-c++98-compat-extra-semi",     "-Wno-c++98-compat-local-type-template-args",      "-Wno-c++98-compat-pedantic", "-Wno-c++98-compat-unnamed-type-template-args",
          // Silence Documentation Errors completely. They don't work for anything other than doxygen rules
          "-Wno-documentation",                 // Ignore for our custom syntax
          "-Wno-documentation-unknown-command", // Ignore for our custom syntax
          "-Wno-documentation-deprecated-sync", // Ignore deprecated tags missing their attribute  (GLFW breaks it)
          // TODO: Remove completely
          "-Wno-error=missing-braces",  // Irrelevant when using -Wmissing-field-initializers
        }; //::  base
        //_____________________________________
        /// @descr Flags to add to the strict list when compiling in Release mode
        pub const release :cstr_List= FlagList.default.C.CC.base ++ &.{
          "-Wno-pre-c2x-compat",       // Explicitly allow < c2x compat, but keep the warnings
          "-Wno-#warnings",            // Explicitly allow user warnings without creating errors
          "-Wno-unsafe-buffer-usage",  // Explicitly avoid erroring on this (half-finished) warning group from clang.16
          "-Wno-vla",                  // Explicitly avoid erroring on VLA usage, but keep the warning (todo: only for debug)
          "-Wno-padded",               // Warn when structs are automatically padded, but don't error.
          "-Wno-unused-macros",        // Macros cannot be declared public to not trigger this, so better to not error and keep the warning
        }; //:: release
        //_____________________________________
        /// @descr Flags to add to the strict list when compiling in Debug mode
        pub const debug :cstr_List= FlagList.default.C.CC.base ++ FlagList.default.C.CC.optim.debug ++ &.{
          // Syntax fixes
          "-Wno-error=pre-c2x-compat",       // Explicitly allow < c2x compat, but keep the warnings
          "-Wno-error=#warnings",            // Explicitly allow user warnings without creating errors
          "-Wno-error=unsafe-buffer-usage",  // Explicitly avoid erroring on this (half-finished) warning group from clang.16
          "-Wno-error=vla",                  // Explicitly avoid erroring on VLA usage, but keep the warning (todo: only for debug)
          "-Wno-error=padded",               // Warn when structs are automatically padded, but don't error.
          "-Wno-error=unused-macros",        // Macros cannot be declared public to not trigger this, so better to not error and keep the warning
          // https://github.com/ziglang/zig/issues/5163
          "-fno-sanitize-trap=undefined",
          "-fno-sanitize-recover=undefined",
        }; //:: debug
      }; //:: strict
    };
    pub const LD = struct {
      pub const base :cstr_List= &.{
      };
      pub const strict = struct {
        const base :cstr_List= &.{
        }; //::  base
        const debug :cstr_List= FlagList.default.C.LD.base ++ &.{
          "-lubsan",
        }; //::  debug
      }; //::  strict
    };
  };
  /// @warning To be done
  const Cpp = struct {
    const CC = struct {
      const base :cstr_List= &.{
        "-std=c++20",
      }; //:: base
      const others :cstr_List= &.{
        "-Wcast-align",
      }; //:: others
    }; //:: CC
  }; //:: Cpp
}; //:: default



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

