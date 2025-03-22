//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Connector cable to all of the Manager modules
//_______________________________________________________________|
// @deps confy
import { ManagerBun } from "./bun"
import { ManagerZig } from "./zig"

export namespace Manager {
  export const Bun = ManagerBun
  export const Zig = ManagerZig
}

