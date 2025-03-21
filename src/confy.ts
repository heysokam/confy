//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import { info } from '@confy/log'
import { Manager } from '@confy/manager'
import { Package } from '@confy/package'
import { Cli, File } from '@confy/tools'

namespace Commands {
  export async function bun () :Promise<void> {
    await Manager.Bun.run(...Cli.raw().slice(3))
  }

  export async function build () :Promise<void> {
    const build_ts = "build.ts"
    if (File.exists(build_ts)) await Manager.Bun.run("run", build_ts, ...Cli.raw().slice(3))
    else                       await Commands.passthrough()
  }

  export async function run () :Promise<void> {
    const build_ts = "build.ts"
    if (File.exists(build_ts)) await Manager.Bun.run("run", build_ts, "run", ...Cli.raw().slice(3))
    else                       await Manager.Bun.run("run", ...Cli.raw().slice(3))
  }

  export async function passthrough () :Promise<void> {
    // FIX: Print help for the default case
    await Manager.Bun.run(...Cli.raw().slice(2))
    info("WARNING: Help output message not yet implemented.")
  }
}

if (import.meta.main) {
  // Add all bun & confy dependencies
  await Manager.Bun.validate()
  await Package.init()
  // Get the CLI arguments
  const cli = Cli.internal()
  // Simple command cases
  switch (cli.args[0]) {
    // Default Cases
    case "build" : await Commands.build() ; break;
    case "run"   : await Commands.run()   ; break;
    // Passthrough commands
    case "bun"   : await Commands.bun()   ; break;
    default      : await Commands.passthrough()
  }
}

//____________________________
// Special commands
//  init
//  init config
//  get [language]
//  zig
//  nim

