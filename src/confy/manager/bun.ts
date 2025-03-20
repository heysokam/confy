//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import { Dir } from '@confy/tools/files'
import * as shell from '@confy/tools/shell'
import { get } from '@confy/get'

export const ManagerBun = {
  exists   : get.Bun.exists,
  path     : () => Dir.cwd()+"/bin/bun",
  validate : async () => await get.Bun.download(ManagerBun.path()),
  run      : async (...args:unknown[]) => await shell.run(ManagerBun.path(), ...args),
}

