//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import * as shell from '../tools/shell'
import { get } from '../get'
import { cfg as confy } from '../cfg'

export namespace Nim {
  export const exists   = get.Nim.exists
  export const validate = async (cfg :confy.Config, force :boolean= false)=> await get.Nim.download(cfg, force)
  export const run      = async (cfg :confy.Config, ...args:unknown[]) => await shell.run(cfg.nim.bin, ...args)
  export const compile  = async (cfg :confy.Config, ...args:unknown[]) => {
    const backend = "c"
    const verbose = (cfg.verbose) ? "--verbosity:2" : (cfg.quiet) ? "--verbosity:0" : "--verbosity:1"
    const hints   = ["--hint:Conf:off", "--hint:SuccessX:off", "--hint:MsgOrigin:off", "--hint:Exec:on", "--hint:Link:on",]
    const warns   = ["--warning:UnusedImport:off"]
    const zigcc   = `${cfg.zig.bin.toString()}cc`
    const zigcpp  = `${cfg.zig.bin.toString()}cpp`
    const nimble  = [`--clearNimblePath`, `--NimblePath:${cfg.nim.nimble.dir.toString()}/pkgs2`]
    const zig     = ["-d:zig",
      "--cc:clang",
      `--clang.exe=${zigcc}`,          `--clang.linkerexe=${zigcc}`,
      `--clang.cppCompiler=${zigcpp}`, `--clang.cppXsupport="-std=c++20"`,
    ]
    const cache = "--nimcache:"+cfg.nim.cache.toString()
    const cmd = [cfg.nim.bin, backend, verbose, ...hints, ...warns, ...nimble, ...zig, cache, ...args]
    if (!cfg.quiet) console.log(...cmd)
    await shell.run(...cmd)
  } //:: Manager.Nim
} //:: Manager.Nim

export const ManagerZig = {
  exists   : Nim.exists,
  validate : Nim.validate,
  run      : Nim.run,
}

