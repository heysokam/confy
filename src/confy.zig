//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview
//!  Confy : Comfortable and Configurable Buildsystem
//!  @todo : Docs here
//_____________________________________________________|
const confy = @This();

//______________________________________
// @section Forward Export zstd tools
//____________________________
const zstd = @import("./lib/zstd.zig");
pub const Name = zstd.Name;
pub const echo = zstd.echo;


//______________________________________
// @section Forward Export Confy tools
//____________________________
pub const init      = @import("./confy/core.zig").init;
pub const Git       = @import("./confy/git.zig");
pub const Package   = @import("./confy/package.zig");
pub const BuildTrg  = @import("./confy/target.zig");
pub const Program   = BuildTrg.Program;
pub const StaticLib = BuildTrg.StaticLib;
pub const SharedLib = BuildTrg.SharedLib;
pub const UnitTest  = BuildTrg.UnitTest;

