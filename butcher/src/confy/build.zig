//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Tools required to connect confy with the default Zig buildsystem.
//! @note
//!  Very minimal functionality. Not too useful in its current state, but does its job.
//!  The current way of running confy is running the `build.zig.sh` script.
//______________________________________________________________________________________|
pub const buildzig = @This();
// @deps std
const std = @import("std");
// @deps zstd
const zstd = @import("../lib/zstd.zig");
const cstr = zstd.cstr;
// @deps confy
const cfg = @import("./cfg.zig");


//______________________________________
// @section Tools to Run confy from build.zig
//____________________________
/// @descr Describes the options required to build the confy builder of the project.
const RunOptions = struct {
  builder  :Builder=  Builder{},
  const Builder = struct {
    src  :cstr=  cfg.default.dir.src++cfg.default.builder++".zig",
    trg  :cstr=  cfg.default.builder,
  };
};


//________________________________________________
/// @descr Compiles+Runs the Confy Builder of the project with the default options.
/// @note Used only to connect to the standard `zig build` calls
pub fn run (B:*std.Build) void { buildzig.run2(B, .{}); }
//________________________________________________
/// @descr Compiles+Runs the Confy Builder of the project with the spectified list of {@arg opt}.
/// @note Used only to connect to the standard `zig build` calls
pub fn run2 (B:*std.Build, opt :buildzig.RunOptions) void {
  const optim   = B.standardOptimizeOption(.{.preferred_optimize_mode= .ReleaseFast});
  const builder = B.addExecutable(.{
    .name             = opt.builder.trg,
    .root_source_file = B.path(opt.builder.src),
    .target           = B.host,
    .optimize         = optim,
    });
  B.installArtifact(builder);
  const builder_run = B.addRunArtifact(builder);
  // Allow the user to pass arguments to the builder with: `zig build run -- arg1 arg2 etc`
  if (B.args) |args| { builder_run.addArgs(args); }
  // Declare the step that runs the confy builder
  const runner = B.step("run", "Build/Run the Confy Builder");
  runner.dependOn(&builder_run.step);
}






//________________________________________________________________________________________________________________
//
// @reference Previous build.zig implementation
//________________________________________________________________________________________________________________

// //______________________________________
// // @section Zig Aliases
// //____________________________
// const zig = struct {
//   const Build      = std.Build;
//   const Step       = std.Build.Step;
//   const Artifact   = std.Build.Step.InstallArtifact;
//   const DefaultDir = zig.Artifact.Options.Dir.default;
//   const CodeModel  = std.builtin.CodeModel;
// };

// //______________________________________
// // @section Private Tools
// //____________________________
// @descr Data required by a target when declared with the default build.zig buildsystem
// const Private = struct {
//   B      :*zig.Build,
//   step   :*zig.Step.Compile,
//   build  :*zig.Artifact,
//   run    :*zig.Step.Run,
// };

// //:_____________________________________________________
// // @fileoverview Confy's Global State
// //______________________________________________|
// const State = @This();
// // @deps std
// const std = @import("std");
//
//
// //______________________________________
// // @section BuildTarget Management State
// //____________________________
// /// @private
// /// @descr Whether or not confy has initialized a target at least once
// pub var initialized :bool= false;
// /// @private
// /// @descr Target Options passed on CLI. Stored globally, since it cannot be requested twice.
// pub var target :std.Build.ResolvedTarget= undefined;
// /// @private
// /// @descr Optimization Options passed on CLI. Stored globally, since it cannot be requested twice.
// pub var optim :std.builtin.OptimizeMode= undefined;
//
//
//
// //______________________________________
// // @section BuildTarget connector for build.zig
// //____________________________
// 
// pub fn declare(trg :*BuildTrg, B :*zig.Build) void {
//   // Store the Builder internally for ergonomic access
//   trg.priv.B = B;
//
//   // Standard target options allows the person running `zig build` to choose what target to build for.
//   // We do not override the defaults, which means that any target is allowed, and the default is native.
//   // Other options for restricting supported target set are available.
//   trg.system = switch (confy.initialized) {
//     false => trg.priv.B.standardTargetOptions(.{}),
//     true  => confy.target,
//     }; // << trg.system
//
//   // Standard optimization options allow the person running `zig build` to select between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
//   // We do not set a preferred release mode, allowing the user to decide how to optimize.
//   trg.optim = switch (confy.initialized) {
//     false => trg.priv.B.standardOptimizeOption(.{}),
//     true  => confy.optim,
//     }; // << trg.optim
//
//   trg.priv.step = switch(trg.kind) {
//     .program => trg.priv.B.addExecutable(.{
//       .name             = trg.trg,
//       .root_source_file = trg.priv.B.path(trg.src),
//       .target           = trg.system,
//       .optimize         = trg.optim,
//       .version          = Version.parse(trg.version) catch unreachable,
//       // @todo
//       .code_model       = zig.CodeModel.default, // @todo How to select the CodeModel 
//       .linkage          = null,// @todo Link modes for executables ??   linkage: ?std.builtin.LinkMode = null,
//       // max_rss: usize = 0,
//       // .link_libc        = true, // @todo Expose this option. (default:   link_libc: ?bool = null, )
//       // single_threaded: ?bool = null,
//       // pic: ?bool = null,
//       // strip: ?bool = null,
//       // unwind_tables: ?bool = null,
//       // omit_frame_pointer: ?bool = null,
//       // sanitize_thread: ?bool = null,
//       // error_tracing: ?bool = null,
//       // use_llvm: ?bool = null,
//       // use_lld: ?bool = null,
//       // zig_lib_dir: ?LazyPath = null,
//       // /// Embed a `.manifest` file in the compilation if the object format supports it.
//       // /// https://learn.microsoft.com/en-us/windows/win32/sbscs/manifest-files-reference
//       // /// Manifest files must have the extension `.manifest`. Can be set regardless of target.
//       // /// The `.manifest` file will be ignored if the target object format does not support embedded manifests.
//       // win32_manifest: ?LazyPath = null,
//       }), // << .program => ...
//
//     .unittest => blk: {
//       // Creates a step for unit testing. This only builds the test executable but does not run it.
//       const tests = trg.priv.B.addTest(.{
//         .name             = trg.trg,
//         .root_source_file = trg.priv.B.path(trg.src),
//         .target           = trg.system,
//         .optimize         = trg.optim,
//         .version          = Version.parse(trg.version) catch unreachable,
//         });
//       trg.priv.run = trg.priv.B.addRunArtifact(tests);
//       // Similar to creating the run step earlier, this exposes a `test` step to the `zig build --help` menu,
//       // providing a way for the user to request running the unit tests.
//       trg.priv.B.step("test", "Run unit tests").dependOn(&tests.step);
//       break :blk tests;
//       },
//       // max_rss: usize = 0,
//       // /// deprecated: use `.filters = &.{filter}` instead of `.filter = filter`.
//       // filter: ?[]const u8 = null,
//       // filters: []const []const u8 = &.{},
//       // test_runner: ?LazyPath = null,
//       // link_libc: ?bool = null,
//       // single_threaded: ?bool = null,
//       // pic: ?bool = null,
//       // strip: ?bool = null,
//       // unwind_tables: ?bool = null,
//       // omit_frame_pointer: ?bool = null,
//       // sanitize_thread: ?bool = null,
//       // error_tracing: ?bool = null,
//       // use_llvm: ?bool = null,
//       // use_lld: ?bool = null,
//       // zig_lib_dir: ?LazyPath = null,
//     .static => trg.priv.B.addStaticLibrary(.{
//       .name             = trg.trg,
//       .root_source_file = trg.priv.B.path(trg.src),
//       .target           = trg.system,
//       .optimize         = trg.optim,
//       .version          = Version.parse(trg.version) catch unreachable,
//       }), // << .static => ...
//     .lib => unreachable,
//   };
//
//   // Update confy's global state
//   confy.initialized = true;
// }
//
// pub fn build2(trg :*BuildTrg, cfg :?struct {
//     run   : bool = false,
//     force : bool = false,
//   }) void {
//   trg.priv.build = trg.priv.B.addInstallArtifact(trg.priv.step, zig.Artifact.Options{
//     .dest_dir       = zig.DefaultDir,
//     .pdb_dir        = zig.DefaultDir,
//     .h_dir          = zig.DefaultDir,
//     .implib_dir     = zig.DefaultDir,
//     .dylib_symlinks = null,
//     .dest_sub_path  = null,
//     }); // << zig.Artifact.Options{ ... }
//
//   // Declares intent for the library to be installed into the standard location
//   // when the user invokes the "install" step (the default step when running `zig build`).
//   trg.priv.B.getInstallStep().dependOn(&trg.priv.build.step);
//
//   if (cfg != null and cfg.?.run) {
//     // *Create* a Run step that executes when another step that depends on it is evaluated.
//     trg.priv.run = trg.priv.B.addRunArtifact(trg.priv.step);
//
//     // Establish the dependency of the run step with the install step.
//     // By making the run step depend on the install step,
//     // the step will be run from the installation directory, rather than directly from within the cache directory.
//     // It is not necessary, but it ensures that the files will be present in the correct location if the application depends on other installed files.
//     trg.priv.run.step.dependOn(trg.priv.B.getInstallStep());
//
//     // Allow the user to pass arguments to the application in the build command: `zig build run -- arg1 arg2 etc`
//     if (trg.priv.B.args) |args| { trg.priv.run.addArgs(args); }
//
//     // Create a run step option.
//     // Will be visible in the `zig build --help` menu, and can be selected with: `zig build run`
//     // This will evaluate the `run` step rather than the default, which is "install".
//     trg.priv.B.step("run", "Run the app")
//       .dependOn(&trg.priv.run.step);
//   }
// }
// pub fn build(trg :*BuildTrg) void { trg.build2(.{}); }

