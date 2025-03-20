//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import { log as echo } from 'console'
// @deps confy
import { cfg_default as cfg } from '@confy/cfg'

export function info (...args:unknown[]) :void {
  echo(cfg.prefix, ...args)
}
