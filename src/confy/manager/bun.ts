//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as shell from '@confy/tools/shell'
import { get } from '@confy/get'
import { cfg as confy } from '@confy/cfg'

export const ManagerBun = {
  exists   : get.Bun.exists,
  validate : async (cfg :confy.Config)=> await get.Bun.download(cfg, /*force=*/false),
  run      : async (cfg :confy.Config, ...args:unknown[]) => await shell.run(cfg.bun.bin, ...args),
}

