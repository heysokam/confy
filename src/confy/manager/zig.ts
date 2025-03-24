//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as shell from '@confy/tools/shell'
import { get } from '@confy/get'
import { cfg as confy } from '@confy/cfg'

export namespace Zig {
  export const exists   = get.Zig.exists
  export const validate = async (cfg :confy.Config)=> await get.Zig.download(cfg, /*force=*/false)
  export const run      = async (cfg :confy.Config, ...args:unknown[]) => await shell.run(cfg.zig.bin, ...args)
}

export const ManagerZig = {
  exists   : Zig.exists,
  validate : Zig.validate,
  run      : Zig.validate,
}
