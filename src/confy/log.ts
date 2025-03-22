//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import { log as echo } from 'console'
// @deps confy
import { defaults as cfg } from '@confy/cfg'

export function info (...args:unknown[]) :void { echo(cfg.prefix, ...args) }
export function fail (...args:unknown[]) :void { throw new Error(cfg.prefix+"Error:" + args.toString()) }
