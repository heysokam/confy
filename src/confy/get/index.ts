//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Connector cable to all of the Get modules
//__________________________________________________________|
// @deps confy
import { BUN as bun } from "./bun"
import { Zig as zig } from "./zig"
import { Nim as nim } from "./nim"

export namespace get {
  export const Bun = bun
  export const Zig = zig
  export const Nim = nim
}

