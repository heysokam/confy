//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import * as fs from 'fs'
import path from 'path';
import * as confy from './tools'
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
  export const scope     = "@heysokam"
  export const pkgName   = `${cfg.tool.scope}/${cfg.tool.name}`  // FIX: @npm/ confy is taken
  export const version   = new confy.Version(0,6,50)
  export const icon      = "ᛝ"
  export const descr     = "Comfortable and Configurable Buildsystem for C, C++, Zig and Nim"
  export const separator = { name: ":", descr: "|" }
  export const cache     = ".cache"
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
 * Configuration options for Bun and its management.
 * */
export type Bun = {
  name       :string
  // version    :NamedVersion | string  // TODO:
  cache      :fs.PathLike
  dir        :fs.PathLike
  bin        :fs.PathLike
  systemBin  :boolean
}

export namespace Version {
  export enum Named { "latest" }
  export type Zig = "master" | "0.14.0" | "0.13.0" | "0.12.1" | "0.12.0" | "0.11.0" | "0.10.1" | "0.10.0"
  export type Nim = "devel" | "version-2-2" | "version-2-0"
  export type Any = string
}

/**
 * @description
 * Configuration options for the Zig compiler and its management.
 * */
export type Zig = {
  name       :string
  version    :Version.Zig | Version.Named | Version.Any // eslint-disable-line @typescript-eslint/no-redundant-type-constituents
  index      :fs.PathLike
  current    :fs.PathLike
  cache      :fs.PathLike
  dir        :fs.PathLike
  bin        :fs.PathLike
  systemBin  :boolean
}

export namespace Git {
  /**
   * @description
   * Represents the configuration data of a git repository
   *
   * @example
   * host       : https://github.com
   * owner      : user
   * repo       : project
   * branch     : branch
   * githubURL  : https://github.com/user/project/tree/branch
   *
   * @warning
   * Only tested with github.
   * Support for generic git hosts is desirable, but has not been implemented.
   * Please open an issue/PR to discuss about it.
   * */
  export type Repository = {
    host    :URL
    owner   :fs.PathLike
    repo    :fs.PathLike
    branch  :fs.PathLike | null
  }
}

/**
 * @description
 * Configuration options for the Nimble Package Manager and its management.
 * */
export type Nimble = {
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
  version    :Version.Nim | Version.Named | Version.Any // eslint-disable-line @typescript-eslint/no-redundant-type-constituents
  git        :cfg.Git.Repository  // @warning Setting a branch will override the version when bootstrapping
  bootstrap  :boolean
  systemBin  :boolean
  nimble     :cfg.Nimble
}

export type Dirs = {
  bin    :fs.PathLike
  src    :fs.PathLike
  lib    :fs.PathLike
  cache  :fs.PathLike
}
export namespace defaults {
  export const sub = {
    src    : "src",
    bin    : "bin",
    lib    : ".lib",
    bun    : ".bun",
    zig    : ".zig",
    nim    : ".nim",
    nimble : ".nimble",
  }

  export function prefix () :string { return `${cfg.tool.icon} ${cfg.tool.name}${cfg.tool.separator.name}` }
  export namespace dir {
    export function src    () :string { return path.join(  ".", cfg.defaults.sub.src          ) }
    export function bin    () :string { return path.join(  ".", cfg.defaults.sub.bin          ) }
    export function lib    () :string { return path.join(bin(), cfg.defaults.sub.lib          ) }
    export function cache  () :string { return path.join(bin(), cfg.tool.cache, cfg.tool.name ) }
  }

  export namespace bun {
    export const name = "bun"
    export function dir     () :string { return path.join(  cfg.defaults.dir.bin(), cfg.defaults.sub.bun) }
    export function bin     () :string { return path.join(               bun.dir(), name                ) }
    export function cache   () :string { return path.join(cfg.defaults.dir.cache(), name                ) }
  }

  export namespace zig {
    export const name         = "zig"
    export const version      = Version.Named.latest
    export const file_index   = name+".index.json"
    export const file_current = name+".version.json"
    export function cache   () :string { return path.join(cfg.defaults.dir.cache(), name                ) }
    export function index   () :string { return path.join(cfg.defaults.dir.cache(), file_index          ) }
    export function current () :string { return path.join(cfg.defaults.dir.cache(), file_current        ) }
    export function dir     () :string { return path.join(  cfg.defaults.dir.bin(), cfg.defaults.sub.zig) }
    export function bin     () :string { return path.join(               zig.dir(), name                ) }
  }

  export namespace nim {
    export const name    = "nim"
    export const binDir  = "bin" // Subfolder where the nim binaries are compiled into
    export const version = Version.Named.latest
    export function dir     () :string { return path.join(  cfg.defaults.dir.bin(), cfg.defaults.sub.nim) }
    export function bin     () :string { return path.join(               nim.dir(), binDir, name        ) }
    export function cache   () :string { return path.join(cfg.defaults.dir.cache(), name                ) }
    export namespace repo {
      export function official () :cfg.Git.Repository { return {
        host   : new URL("https://github.com"),
        owner  : "nim-lang",
        repo   : "Nim",
        branch : null
      }}
    }
    export namespace nimble {
      export function dir () :string { return path.join(cfg.defaults.dir.bin(), cfg.defaults.sub.nimble       ) }
      export function bin () :string { return path.join(cfg.defaults.dir.bin(), cfg.defaults.sub.nimble, name ) }
    }
  }

  export namespace pkg {
    export function info () :cfg.Package.Info { return {
      // Required Preset
      version         : "0.0.0",
      dependencies    : { [cfg.tool.pkgName]: "^"+cfg.tool.version.toString() },
      devDependencies : { [cfg.tool.pkgName]: "^"+cfg.tool.version.toString() },
      // Required Unknown
      // We consider these required. The schema doesn't. Shouldn't be null. We cast for safety
      name            : null as unknown as string,
      description     : null as unknown as string,
      license         : null as unknown as string,
      homepage        : null as unknown as string,
      // Optional fields
      // Non-configurable fields
      $schema         : "https://json.schemastore.org/package.json",
    }}
  }

  export function clone () :Config { return {
    prefix        : cfg.defaults.prefix(),
    verbose       : true,
    quiet         : false,
    force         : false,
    pkg           : cfg.defaults.pkg.info(),
    dir           : {
      src         : cfg.defaults.dir.src(),
      lib         : cfg.defaults.dir.lib(),
      bin         : cfg.defaults.dir.bin(),
      cache       : cfg.defaults.dir.cache(),
    },
    bun           : {
      name        : bun.name,
      cache       : bun.cache(),
      dir         : bun.dir(),
      bin         : bun.bin(),
      systemBin   : false,
    },
    zig           : {
      name        : zig.name,
      version     : zig.version,
      index       : zig.index(),
      current     : zig.current(),
      cache       : zig.cache(),
      dir         : zig.dir(),
      bin         : zig.bin(),
      systemBin   : false,
    },
    nim           : {
      name        : nim.name,
      cache       : nim.cache(),
      dir         : nim.dir(),
      bin         : nim.bin(),
      git         : nim.repo.official(),
      version     : nim.version,
      systemBin   : false,
      bootstrap   : true,
      nimble      : {
        dir       : nim.nimble.dir(),
        bin       : nim.nimble.bin(),
        systemBin : false,
      }
    },
  }}
}
export namespace Package {
  export type Dependencies = Record<string, string> & {[cfg.tool.pkgName]: string}
  export type Info = {
    $schema          :"https://json.schemastore.org/package.json",
    name             :string
    description      :string
    version          :string | confy.Version
    license          :string
    homepage         :string
    // cfg.tool.name:cfg.tool.version  must exist, or else it will be added to devDependencies
    dependencies    ?:Package.Dependencies
    devDependencies ?:Package.Dependencies
  } & Record<string, any> // eslint-disable-line @typescript-eslint/no-explicit-any
}

export type Config = {
  prefix   :string
  verbose  :boolean
  quiet    :boolean
  force    :boolean
  pkg      :cfg.Package.Info
  dir      :cfg.Dirs
  zig      :cfg.Zig
  nim      :cfg.Nim
  bun      :cfg.Bun
}

} //:: cfg

export const defaults = cfg.defaults.clone

