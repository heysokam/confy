//:_____________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
//:_____________________________________________________
//! @fileoverview Confy's Global State
//______________________________________________|
const State = @This();
// @deps std
const std = @import("std");


//______________________________________
// @section BuildTarget Management State
//____________________________
/// @private
/// @descr Whether or not confy has initialized a target at least once
pub var initialized :bool= false;
/// @private
/// @descr Target Options passed on CLI. Stored globally, since it cannot be requested twice.
pub var target :std.Build.ResolvedTarget= undefined;
/// @private
/// @descr Optimization Options passed on CLI. Stored globally, since it cannot be requested twice.
pub var optim :std.builtin.OptimizeMode= undefined;

