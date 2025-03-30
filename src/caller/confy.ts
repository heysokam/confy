//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import * as log from './confy/log'
import { Manager } from './confy/manager'
// import { Package } from './confy/package'
import { File, Dir, Path } from './confy/tools/files'
import { cfg as confy } from './confy/cfg'
import { Cli as ConfyCLI } from './confy/tools/cli'
import { shell } from './confy/tools'
type Cli = ConfyCLI.Internal

namespace Commands {
  //______________________________________
  // @section Builder Commands: build
  //____________________________
  export namespace Builder {
    export const entry = "build.nim"
    export function exists (
        cfg : confy.Config,
        cli : Cli
      ) :boolean {
      cfg;cli;/*discard*/ // eslint-disable-line @typescript-eslint/no-unused-expressions
      const default_entry = File.exists(Builder.entry)
      return default_entry
    }

    export async function run (
        cfg     : confy.Config,
        cli     : Cli,
        ...args : unknown[]
      ) :Promise<void> {
      cli;/*discard*/ // eslint-disable-line @typescript-eslint/no-unused-expressions
      // FIX: Needs to pass --path for local confy
      const trg = Path.join(cfg.dir.cache, Path.name(Builder.entry))
      const out = "-o:"+trg.toString()
      await Manager.Nim.compile(cfg, "-d:release", out, Builder.entry)
      await shell.run(trg, ...args, ...ConfyCLI.raw().slice(3))
    }
  }

  export namespace Build {
    export async function requirements (
        cfg : confy.Config,
        cli : Cli
      ) :Promise<void> {
      cli;/*discard*/ // eslint-disable-line @typescript-eslint/no-unused-expressions
      await Manager.Zig.validate(cfg)
      await Manager.Nim.validate(cfg)
      // Add confy+libs+config to the package (when needed)
      // await Package.init(cfg)
    } //:: Commands.Build.requirements
  } //:: Commands.Build

  export async function build (
      cfg : confy.Config,
      cli : Cli
    ) :Promise<void> {
    if (!Builder.exists(cfg, cli)) return Commands.anything(cfg)
    await Commands.Build.requirements(cfg, cli)
    await Builder.run(cfg, cli)
  }


  //______________________________________
  // @section Builder Commands: run
  //____________________________
  export async function run (
      cfg : confy.Config,
      cli : Cli
    ) :Promise<void> {
    if (!Builder.exists(cfg, cli)) await Manager.Bun.run(cfg, "run", ...ConfyCLI.raw().slice(3))
    await Builder.run(cfg, cli, "run")
  }


  //______________________________________
  // @section Helper Commands: init
  //____________________________
  export async function init ( // eslint-disable-line @typescript-eslint/require-await
      cfg : confy.Config,
      cli : Cli
    ) :Promise<void> { log.fail(cfg, "Command `init` not yet implemented.", JSON.stringify(cli)); }


  //______________________________________
  // @section Helper Commands: get
  //____________________________
  export namespace Get {
    export namespace opts {
      export const force = (cli :Cli) :boolean=> cli.opts.short.has("f")
    }

    namespace remap {
      export function bun (cfg :confy.Config) :void {
        cfg.dir.cache = Path.join(Dir.current(), confy.tool.cache)
        cfg.bun.cache = Path.join(cfg.dir.cache, confy.defaults.sub.bun)
        cfg.bun.dir   = Path.join(Dir.current(), confy.defaults.sub.bun)
        cfg.bun.bin   = Path.join(cfg.bun.dir, confy.defaults.bun.name)
      }
      export function zig (cfg :confy.Config) :void {
        cfg.dir.cache   = Path.join(Dir.current(), confy.tool.cache)
        cfg.zig.cache   = Path.join(cfg.dir.cache, confy.defaults.sub.zig)
        cfg.zig.dir     = Path.join(Dir.current(), confy.defaults.sub.zig)
        cfg.zig.bin     = Path.join(cfg.zig.dir, confy.defaults.zig.name)
        cfg.zig.index   = Path.join(cfg.zig.cache, confy.defaults.zig.file_index)
        cfg.zig.current = Path.join(cfg.zig.cache, confy.defaults.zig.file_current)
      }
      export function nim (cfg :confy.Config) :void {
        remap.zig(cfg)
        cfg.dir.cache = Path.join(Dir.current(), confy.tool.cache)
        cfg.nim.cache = Path.join(cfg.dir.cache, confy.defaults.sub.nim)
        cfg.nim.dir   = Path.join(Dir.current(), confy.defaults.sub.nim)
        cfg.nim.bin   = Path.join(cfg.nim.dir, confy.defaults.nim.name)
      }
    }

    export async function bun (
        cfg : confy.Config,
        cli : Cli
      ) :Promise<void> {
      if (!Dir.exists(cfg.dir.bin)) remap.bun(cfg)
      const force = Commands.Get.opts.force(cli)
      await Manager.Bun.validate(cfg, force)
    }

    export async function zig (
        cfg : confy.Config,
        cli : Cli
      ) :Promise<void> {
      if (!Dir.exists(cfg.dir.bin)) remap.zig(cfg)
      const force = Commands.Get.opts.force(cli)
      await Manager.Zig.validate(cfg, force)
    }

    export async function nim (
        cfg : confy.Config,
        cli : Cli
      ) :Promise<void> {
      if (!Dir.exists(cfg.dir.bin)) remap.nim(cfg)
      const force = Commands.Get.opts.force(cli)
      await Manager.Zig.validate(cfg, force)
      await Manager.Nim.validate(cfg, force)
    } //:: Commands.Get.nim
  } //:: Commands.Get

  export async function get (
      cfg : confy.Config,
      cli : Cli
    ) :Promise<void> {
    if (cli.args[0] !== "get") log.fail(cfg, "Command: Tried to call `confy get` incorrectly. The get argument must be first.", JSON.stringify(cli))  // External unsafe usage sanity
    switch (cli.args[1]) {
      case "bun" : return Commands.Get.bun(cfg, cli)
      case "zig" : return Commands.Get.zig(cfg, cli)
      case "nim" : return Commands.Get.nim(cfg, cli)
      default    : log.fail(cfg, `Command: \`confy get ${cli.args[1] ?? ""}\` is not a known get command.`, cfg.verbose ? JSON.stringify(cli) : "")  // External unsafe usage sanity
    }
  }


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
    const cmd = ConfyCLI.raw().slice(3)
    log.verb(cfg, `Running ${(name) ? name + " " : ""}command in passthrough mode:\n `, bin, ...cmd)
    await run(cfg, ...cmd)
  }

  // export async function sh (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.bun.bin, "Bun", Manager.Bun.run) }
  export async function bun (cfg :confy.Config) :Promise<void> { await Commands.passthrough(cfg, cfg.bun.bin, "Bun", Manager.Bun.run) }  // We always validate bun at the start
  export async function zig (cfg :confy.Config) :Promise<void> { await Commands.passthrough(cfg, cfg.zig.bin, "Zig", Manager.Zig.run, Manager.Zig.validate) }

  export async function nim (cfg :confy.Config) :Promise<void> { await Commands.passthrough(cfg, cfg.nim.bin, "Nim", Manager.Nim.run, Manager.Nim.validate) }
  // export async function nimble    (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.nim.nimble.bin, "Nimble", Manager.Nimble.run, Manager.Nimble.validate) }
  // export async function atlas     (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.nim.atlas.bin, "Atlas", Manager.Atlas.run, Manager.Atlas.validate) }
  // export async function nimpretty (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.nim.nimpretty.bin, "NimPretty", Manager.NimPretty.run, Manager.NimPretty.validate) }
  // export async function testament (cfg :confy.Config) :Promise<void> { Commands.passthrough(cfg, cfg.nim.testament.bin, "Testament", Manager.Testament.run, Manager.Testament.validate) }

  export async function anything (cfg :confy.Config) :Promise<void> { // eslint-disable-line @typescript-eslint/require-await
    // FIX: Print help for the default case
    // await Manager.Bun.run(...ConfyCLI.raw().slice(2))
    log.warn(cfg, "Help output message not yet implemented.")
    // Find the file with arg0's name
    //   ok . Run the file with arg0's name
    //   err. Print help message
    //    ??  Try system command? :think:
  }
}


//______________________________________
// @section Entry Point: confy
//____________________________
if (import.meta.main) void run()
async function run () :Promise<void> {
  // Get the confy's internal Config and CLI arguments
  const cfg = confy.defaults.clone()
  const cli = ConfyCLI.internal()

  // Command cases
  switch (cli.args[0]) {
    // Default Cases
    case undefined : await Commands.build(cfg, cli) ; break;
    case "build"   : await Commands.build(cfg, cli) ; break;
    case "run"     : await Commands.run(cfg, cli)   ; break;
    case "get"     : await Commands.get(cfg, cli)   ; break;
    // Passthrough commands
    case "bun"     : await Commands.bun(cfg)        ; break;
    case "zig"     : await Commands.zig(cfg)        ; break;
    case "nim"     : await Commands.nim(cfg)        ; break;
    default        : await Commands.anything(cfg)
  }
}

//____________________________
// Special commands
//  init
//  init config
//  tag

