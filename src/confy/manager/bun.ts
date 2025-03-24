//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as shell from '@confy/tools/shell'
import { get } from '@confy/get'
import { cfg as confy } from '@confy/cfg'

export namespace BUN {
  export const exists   = get.Bun.exists
  export const validate = async (cfg :confy.Config)=> await get.Bun.download(cfg, /*force=*/false)
  export const run      = async (cfg :confy.Config, ...args:unknown[]) => await shell.run(cfg.bun.bin, ...args)
}

export const ManagerBun = {
  exists   : BUN.exists,
  validate : BUN.validate,
  run      : BUN.run,
}

