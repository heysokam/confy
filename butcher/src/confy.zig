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
pub const Name      = zstd.Name;
pub const echo      = zstd.echo;
pub const Lang      = zstd.Lang;
pub const System    = zstd.System;
pub const shell     = zstd.shell;


//______________________________________
// @section Forward Export Confy tools
//____________________________
pub const Git = @import("./confy/git.zig");

