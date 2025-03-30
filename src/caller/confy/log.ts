//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import { log as echo } from 'console'
// @deps confy
import { cfg as confy, defaults } from './cfg'

export function info (C :confy.Config, ...args:unknown[]) :void { echo(confy.pfx.info (C), ...args)}
export function warn (C :confy.Config, ...args:unknown[]) :void { echo(confy.pfx.warn (C), ...args)}
export function err  (C :confy.Config, ...args:unknown[]) :void { echo(confy.pfx.error(C), ...args)}
export function dbg  (C :confy.Config, ...args:unknown[]) :void { echo(confy.pfx.debug(C), ...args)}
export function fail (C :confy.Config, ...args:unknown[]) :void { throw new Error([confy.pfx.fatal(C), ...args, new Error().stack].join(" ")) }
export function verb (C :confy.Config, ...args:unknown[]) :void { if (C.verbose) info(C,  ...args)}

const log = { info, verb, warn, err, dbg, fail }
export namespace Default {
  const config = defaults()
  export function info (...args:unknown[]) :void { log.info(config, ...args) }
  export function verb (...args:unknown[]) :void { log.verb(config, ...args) }
  export function warn (...args:unknown[]) :void { log.warn(config, ...args) }
  export function err  (...args:unknown[]) :void { log.err (config, ...args) }
  export function dbg  (...args:unknown[]) :void { log.dbg (config, ...args) }
  export function fail (...args:unknown[]) :void { log.fail(config, ...args) }
}

