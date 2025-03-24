//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import * as fs from 'fs'
import path from 'path';
export default cfg; export namespace cfg {

/**
 * @description
 * Describes the configuration specific to the tool that is running the user's buildsystem code.
 *
 * @private
 * Exposed for clarity.
 * This is not meant to represent the user's buildsystem code,
 * but rather the internal configuration of this package.
 * Its data will be used to create the root package.json at buildtime.
 * */
export namespace tool {
  export const name      = "confy"
  export const version   = "0.6.50"
  export const icon      = "ᛝ"
  export const descr     = "Comfortable and Configurable Buildsystem"
  export const separator = { name: ":", descr: "|" }
  export const cache     = ".cache/confy"
}

/** @description Prefixes added to logging messages */
export namespace pfx {
  export const info  = (C :Config) :string=> C.prefix+""
  export const warn  = (C :Config) :string=> C.prefix+" ⚠ Warning ⚠"
  export const error = (C :Config) :string=> C.prefix+" ❌ Error ❌"
  export const fatal = (C :Config) :string=> C.prefix+" ⛔ Error ⛔"
  export const debug = (C :Config) :string=> C.prefix+" 🐜 Debug 🐜"
}


/**
 * @description
 * Configuration options for the Zig compiler and its management.
 * */
export type Bun = {
  name       :string
  // version    :NamedVersion | string  // TODO:
  cache      :fs.PathLike
  dir        :fs.PathLike
  bin        :fs.PathLike
  systemBin  :boolean
}

export enum NamedVersion { "master", "latest" }
/**
 * @description
 * Configuration options for the Zig compiler and its management.
 * */
export type Zig = {
  name       :string
  version    :NamedVersion | string
  index      :fs.PathLike
  current    :fs.PathLike
  cache      :fs.PathLike
  dir        :fs.PathLike
  bin        :fs.PathLike
  systemBin  :boolean
}

/**
 * @description
 * Configuration options for the Nim compiler and its management.
 * */
export type Nim = {
  name       :string
  cache      :fs.PathLike
  dir        :fs.PathLike
  bin        :fs.PathLike
  bootstrap  :boolean
  systemBin  :boolean
}

export type Dirs = {
  bin    :fs.PathLike
  src    :fs.PathLike
  lib    :fs.PathLike
  cache  :fs.PathLike
}
export namespace defaults {
  export const sub = {
    src : "src",
    bin : "bin",
    lib : ".lib",
    zig : ".zig",
    nim : ".nim",
    bun : ".bun",
  }

  export function prefix () :string { return `${cfg.tool.icon} ${cfg.tool.name}${cfg.tool.separator.name}` }
  export namespace dir {
    export function src    () :string { return path.join(  ".", cfg.defaults.sub.src) }
    export function bin    () :string { return path.join(  ".", cfg.defaults.sub.bin) }
    export function lib    () :string { return path.join(bin(), cfg.defaults.sub.lib) }
    export function cache  () :string { return path.join(bin(), cfg.tool.cache      ) }
  }
  export namespace zig {
    export const name    = "zig"
    export const version = NamedVersion.latest
    export function cache   () :string { return path.join(cfg.defaults.dir.cache(), name                ) }
    export function index   () :string { return path.join(cfg.defaults.dir.cache(), name+".index.json"  ) }
    export function current () :string { return path.join(cfg.defaults.dir.cache(), name+".version.json") }
    export function dir     () :string { return path.join(  cfg.defaults.dir.bin(), cfg.defaults.sub.zig) }
    export function bin     () :string { return path.join(               zig.dir(), name                ) }
  }

  export namespace nim {
    export const name = "nim"
    export function dir     () :string { return path.join(  cfg.defaults.dir.bin(), cfg.defaults.sub.nim) }
    export function bin     () :string { return path.join(               nim.dir(), name                ) }
    export function cache   () :string { return path.join(cfg.defaults.dir.cache(), name                ) }
  }

  export namespace bun {
    export const name = "bun"
    export function dir     () :string { return path.join(  cfg.defaults.dir.bin(), cfg.defaults.sub.bun) }
    export function bin     () :string { return path.join(               bun.dir(), name                ) }
    export function cache   () :string { return path.join(cfg.defaults.dir.cache(), name                ) }
  }

  export function clone () :Config { return {
    prefix      : cfg.defaults.prefix(),
    verbose     : true,
    quiet       : false,
    force       : false,
    dir         : {
      src       : cfg.defaults.dir.src(),
      lib       : cfg.defaults.dir.lib(),
      bin       : cfg.defaults.dir.bin(),
      cache     : cfg.defaults.dir.cache(),
    },
    zig         : {
      name      : zig.name,
      version   : zig.version,
      index     : zig.index(),
      current   : zig.current(),
      cache     : zig.cache(),
      dir       : zig.dir(),
      bin       : zig.bin(),
      systemBin : false,
    },
    nim         : {
      /* TODO: */
      name      : nim.name,
      cache     : nim.cache(),
      dir       : nim.dir(),
      bin       : nim.bin(),
      systemBin : false,
      bootstrap : true,
    },
    bun         : {
      name      : bun.name,
      cache     : bun.cache(),
      dir       : bun.dir(),
      bin       : bun.bin(),
      systemBin : false,
    },
  }}
}


export type Config = {
  prefix   :string
  verbose  :boolean
  quiet    :boolean
  force    :boolean
  dir      :cfg.Dirs
  zig      :cfg.Zig
  nim      :cfg.Nim
  bun      :cfg.Bun
}

} //:: cfg

export const defaults = cfg.defaults.clone

