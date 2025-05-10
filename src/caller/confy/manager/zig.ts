//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as shell from '../tools/shell'
import { get } from '../get'
import { cfg as confy } from '../cfg'

export namespace Zig {
  export const exists   = get.Zig.exists
  export const validate = async (cfg :confy.Config, force :boolean= false)=> await get.Zig.download(cfg, force)
  export const run      = async (cfg :confy.Config, ...args:unknown[]) => await shell.run(cfg.zig.bin, ...args)
} //:: Manager.Zig

export const ManagerZig = {
  exists   : Zig.exists,
  validate : Zig.validate,
  run      : Zig.run,
}
