//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Connector cable to all of the Get modules
//__________________________________________________________|
// @deps confy
import { getBun } from "./bun";
import { getZig } from "./zig";

export namespace get {
  export const Bun = getBun
  export const Zig = getZig
}

