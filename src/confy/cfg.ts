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
  export const version   = "0.0.0"
  export const icon      = "ᛝ"
  export const descr     = "Comfortable and Configurable Buildsystem"
  export const separator = { name: ":", descr: "|" }
  export const cache     = ".cache/confy"
}

/**
 * @description
 * Configuration options for the Zig compiler and its management.
 * */
export type Bun = {
  index      :fs.PathLike
  current    :fs.PathLike
  cache      :fs.PathLike
  systemBin  :boolean
}

/**
 * @description
 * Configuration options for the Zig compiler and its management.
 * */
export type Zig = {
  index      :fs.PathLike
  current    :fs.PathLike
  cache      :fs.PathLike
  systemBin  :boolean
}

/**
 * @description
 * Configuration options for the Nim compiler and its management.
 * */
export type Nim = {
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
  function prefix () :string { return `${cfg.tool.icon} ${cfg.tool.name}${cfg.tool.separator.name}` }
  function bin    () :string { return path.join(".", "bin") }
  function lib    () :string { return path.join(bin(), ".lib") }

  export function clone () :Config { return structuredClone({
    prefix      : prefix(),
    verbose     : false,
    quiet       : false,
    force       : false,
    dir         : {
      src       : "src",
      lib       : lib(),
      bin       : bin(),
      cache     : cfg.tool.cache,
    },
    zig         : {
      index     : "zig.index.json",
      current   : "zig.version.json",
      cache     : "zig",
      systemBin : false,
    }
  })}
}


export type Config = {
  prefix   :string
  verbose  :boolean
  quiet    :boolean
  force    :boolean
  dir      :cfg.Dirs
  zig      :cfg.Zig
}

} //:: cfg

export const defaults = cfg.defaults.clone()

