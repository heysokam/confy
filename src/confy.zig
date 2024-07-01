//:_____________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
//:_____________________________________________________
//! @fileoverview
//!  Confy : Comfortable and Configurable Buildsystem
//!  @todo : Docs here
//_____________________________________________________|
const confy = @This();

//______________________________________
// @section Forward Export zstd tools
//____________________________
const zstd = @import("zstd");
pub const Name = zstd.Name;


//______________________________________
// @section Forward Export Confy tools
//____________________________
pub const Git      = @import("./confy/git.zig");
pub const Package  = @import("./confy/package.zig");
pub const BuildTrg = @import("./confy/target.zig");

