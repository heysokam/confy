//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as log from '@confy/log'
import { Manager } from '@confy/manager'
import { Package } from '@confy/package'
import { Cli, File } from '@confy/tools'
import { cfg as confy } from '@confy/cfg'

namespace Commands {
  const build_ts = "build.ts"
  export async function build (cfg :confy.Config) :Promise<void> {
    if (File.exists(build_ts)) await Manager.Bun.run(cfg, "run", build_ts, ...Cli.raw().slice(3))
    else                       await Commands.passthrough(cfg)
  }

  export async function run (cfg :confy.Config) :Promise<void> {
    if (File.exists(build_ts)) await Manager.Bun.run(cfg, "run", build_ts, "run", ...Cli.raw().slice(3))
    else                       await Manager.Bun.run(cfg, "run", ...Cli.raw().slice(3))
  }

  export async function passthrough (cfg :confy.Config) :Promise<void> {
    // FIX: Print help for the default case
    // await Manager.Bun.run(...Cli.raw().slice(2))
    log.warn(cfg, "Help output message not yet implemented.")
  }

  export async function get (cfg :confy.Config) :Promise<void> {
    log.info(cfg, "Command `get` not yet implemented.")
  }

  export async function bun (cfg :confy.Config) :Promise<void> {
    const cmd = Cli.raw().slice(3)
    log.verb(cfg, "Running Bun command in passthrough mode:\n ", cfg.bun.bin, ...cmd)
    await Manager.Bun.run(cfg, ...Cli.raw().slice(3))
  }

  export async function zig (cfg :confy.Config) :Promise<void> {
    await Manager.Zig.validate(cfg)
    const cmd = Cli.raw().slice(3)
    log.verb(cfg, "Running Zig command in passthrough mode:\n ", cfg.zig.bin, ...cmd)
    await Manager.Zig.run(cfg, ...cmd)
  }
}




if (import.meta.main) run()
async function run () :Promise<void> {
  // Get the CLI arguments
  const cfg = confy.defaults.clone()
  const cli = Cli.internal()
  // Add all bun & confy dependencies
  await Manager.Bun.validate(cfg)
  await Package.init(cfg)

  // Command cases
  switch (cli.args[0]) {
    // Default Cases
    case "build" : await Commands.build(cfg) ; break;
    case "run"   : await Commands.run(cfg)   ; break;
    case "get"   : await Commands.get(cfg)   ; break;
    // Passthrough commands
    case "zig"   : await Commands.zig(cfg)   ; break;
    case "bun"   : await Commands.bun(cfg)   ; break;
    default      : await Commands.passthrough(cfg)
  }
}

//____________________________
// Special commands
//  init
//  init config
//  get [language]
//  zig
//  nim

