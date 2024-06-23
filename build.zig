//:_____________________________________________________________________
//  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//:_____________________________________________________________________
//! @fileoverview                                      |
//!  Dummy connector for compiling the `confy` caller  |
//!  See ./confy.zig for documentation                 |
//_____________________________________________________|
const Build = @import("std").Build;
const self = @import("confy.zig").P_;
pub fn build(b :*Build) void { self._init(b); }
