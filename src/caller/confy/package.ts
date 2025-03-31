//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Tools for Package Management
//_____________________________________________|
// @deps libs
import * as git from 'simple-git'
// @deps confy
import { File, Dir, Path } from './tools/files'
import { cfg } from './cfg'
import { Manager } from './manager'
const confy = cfg.defaults.clone()
export namespace Package {


export namespace paths {
  export const modules  = "node_modules"
  export const libs     = Path.join(confy.dir.cache, "lib")
  export const tool     = Path.join(paths.libs, cfg.tool.name)
  // export const tool  = Path.join(paths.modules, cfg.tool.pkgName) // @note Outdated Bun+TS code
  export const json     = "package.json"
  export const info     = "info.nim"
  export const lock_bun = "bun.lock"
  export const lock_npm = "package-lock.json"
} //:: confy.Package.files

export const dependencies = [
  {name: "confy", url: "https://github.com/heysokam/confy", subdir: "src"},
  {name: "nstd",  url: "https://github.com/heysokam/nstd",  subdir: "src"},
]

export namespace create {
  export async function dependencies () :Promise<void> {
    for (const dep of Package.dependencies) {
      const dir = Path.join(Package.paths.libs, dep.name)
      if (Dir.exists(dir)) continue
      if (!Dir.exists(confy.dir.cache)) Dir.create(confy.dir.cache)
      // FIX: Generic git clone
      const cmd  = git.simpleGit()
      const opts = ["-j8", "--depth=1", "--recurse-submodules"]
      await cmd.clone(dep.url, dir.toString(), opts)
    }
  }

  export async function requirements_TS () :Promise<void> {
    File.create(Package.paths.json) // @remember Does nothing if it already exists
    await Manager.Bun.run(confy, "add", "-D", cfg.tool.name)
    await Manager.Bun.run(confy, "install")
  }

  export function info () { return }
}

export namespace has {
  export const info   = ():boolean=> File.exists(Package.paths.info)
  export const module = ():boolean=> Dir.exists(paths.tool)

  export function dependencies () :boolean {
    for (const dep of Package.dependencies) {
      const dir = Path.join(Package.paths.libs, dep.name)
      if (!Dir.exists(dir)) return false
    }
    return true
  }

  // FIX: Separate into dependencies and module
  export function requirements_TS () :boolean {
    if (!Package.has.info()) return false
    const json = Package.get.info()
    if (!json.dependencies && !json.devDependencies) return false
    const inDeps    = typeof json.dependencies    === 'object' && cfg.tool.pkgName in json.dependencies
    const inDevDeps = typeof json.devDependencies === 'object' && cfg.tool.pkgName in json.devDependencies
    const installed = Package.has.module()
    return inDevDeps || inDeps || installed
  }
} //:: confy.Package.has


export namespace get {
  export function info() :cfg.Package.Info {
    try   { return JSON.parse(File.read(Package.paths.json).toString()) as cfg.Package.Info }
    catch { return {} as cfg.Package.Info }
  }
} //:: confy.Package.get


export async function init () :Promise<void> {
  const pkg = Package.get.info()
  if (pkg.name === "confy") return
  if (!Package.has.dependencies()) await Package.create.dependencies()
  // FIX: Package.create.info()
} //:: confy.Package.init

} //:: confy.Package

