//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import * as log from '@confy/log'
import { Manager } from '@confy/manager'
import { Package } from '@confy/package'
import { Cli, File } from '@confy/tools'
import { cfg as confy } from '@confy/cfg'

namespace Commands {
  //______________________________________
  // @section Builder Commands
  //____________________________
  const build_ts = "build.ts"
  export async function build (cfg :confy.Config) :Promise<void> {
    if (File.exists(build_ts)) await Manager.Bun.run(cfg, "run", build_ts, ...Cli.raw().slice(3))
    else                       await Commands.anything(cfg)
  }

  export async function run (cfg :confy.Config) :Promise<void> {
    if (File.exists(build_ts)) await Manager.Bun.run(cfg, "run", build_ts, "run", ...Cli.raw().slice(3))
    else                       await Manager.Bun.run(cfg, "run", ...Cli.raw().slice(3))
  }


  //______________________________________
  // @section Helper Commands
  //____________________________
  export async function init (cfg :confy.Config) :Promise<void> { log.info(cfg, "Command `init` not yet implemented.") }
  export async function get  (cfg :confy.Config) :Promise<void> { log.info(cfg, "Command `get` not yet implemented." ) }


  //______________________________________
  // @section Passthrough Commands
  //____________________________
  type FnValidate = (cfg :confy.Config) => Promise<void>
  type FnRun      = (cfg :confy.Config, ...args:unknown[]) => Promise<void>
  export async function passthrough (
      cfg       : confy.Config,
      bin       : fs.PathLike,
      name      : string,
      run       : FnRun,
      validate ?: FnValidate,
    ) :Promise<void> {
    if (validate) await validate(cfg)
    const cmd = Cli.raw().slice(3)
    log.verb(cfg, `Running ${(name) ? name + " " : ""}command in passthrough mode:\n `, bin, ...cmd)
    await run(cfg, ...cmd)
  }

  export async function bun (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.bun.bin, "Bun", Manager.Bun.run) }  // We always validate bun at the start
  export async function zig (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.zig.bin, "Zig", Manager.Zig.run, Manager.Zig.validate) }
  export async function nim (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.nim.bin, "Nim", Manager.Nim.run, Manager.Nim.validate) }
  export async function anything (cfg :confy.Config) :Promise<void> {
    // FIX: Print help for the default case
    // await Manager.Bun.run(...Cli.raw().slice(2))
    log.warn(cfg, "Help output message not yet implemented.")
  }
}


//______________________________________
// @section Entry Point: confy
//____________________________
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
    case "bun"   : await Commands.bun(cfg)   ; break;
    case "zig"   : await Commands.zig(cfg)   ; break;
    case "nim"   : await Commands.nim(cfg)   ; break;
    default      : await Commands.anything(cfg)
  }
}

//____________________________
// Special commands
//  init
//  init config
//  get [language]
//  nim

