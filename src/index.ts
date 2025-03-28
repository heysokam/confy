//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Confy : Comfortable and Configurable Buildsystem
//!  @todo : Docs here
//_____________________________________________________|

//______________________________________
// @section Forward Export: General tools
//____________________________
export { info } from './confy/log'

//______________________________________
// @section Forward Export: Confy tools
//____________________________
export { Program } from './confy/program'
export * from './confy/tools'

/*
pub const Name      = zstd.Name;
pub const Lang      = zstd.Lang;
pub const System    = zstd.System;
pub const shell     = zstd.shell;


pub const Confy      = @import("./confy/core.zig").Confy;
pub const init       = @import("./confy/core.zig").init;
pub const Package    = @import("./confy/package.zig");
pub const BuildTrg   = @import("./confy/target.zig");
pub const Program    = BuildTrg.Program;
pub const StaticLib  = BuildTrg.StaticLib;
pub const SharedLib  = BuildTrg.SharedLib;
pub const UnitTest   = BuildTrg.UnitTest;
pub const CodeList   = @import("./confy/code.zig");
pub const FlagList   = @import("./confy/flags.zig");
pub const Dependency = @import("./confy/dependency.zig");
*/
