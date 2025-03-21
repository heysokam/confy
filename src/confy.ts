//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import { info } from '@confy/log'
import { Manager } from '@confy/manager'
import { CLI } from '@confy/tools/cli'

if (import.meta.main) {
  await Manager.Bun.validate()
  info(await Manager.Bun.run("--version"))
  info(Bun.argv)
  info(new CLI())
}

// Cmd: build
//    Create: bin
//    Get: bun
//    Run: bun i
//    Run: bun run build.ts

