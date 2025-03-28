//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as shell from '../tools/shell'
import { get } from '../get'
import { cfg as confy } from '../cfg'

export namespace Nim {
  export const exists   = get.Nim.exists
  export const validate = async (cfg :confy.Config)=> await get.Nim.download(cfg, /*force=*/false)
  export const run      = async (cfg :confy.Config, ...args:unknown[]) => await shell.run(cfg.nim.bin, ...args)
} //:: Manager.Nim

export const ManagerZig = {
  exists   : Nim.exists,
  validate : Nim.validate,
  run      : Nim.run,
}
