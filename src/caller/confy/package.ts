//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Tools for Package Management
//_____________________________________________|
import { Manager } from './manager'
import { File, Dir, Path } from './tools/files'
import { cfg } from './cfg'
const confy = cfg.defaults.clone()
export namespace Package {


export namespace paths {
  export const modules  = "node_modules"
  export const tool     = Path.join(paths.modules, cfg.tool.pkgName)
  export const json     = "package.json"
  export const lock_bun = "bun.lock"
  export const lock_npm = "package-lock.json"
} //:: confy.Package.files

export namespace create {
  export async function requirements () :Promise<void> {
    File.create(Package.paths.json) // @remember Does nothing if it already exists
    await Manager.Bun.run(confy, "add", "-D", cfg.tool.name)
    await Manager.Bun.run(confy, "install")
  }
  export function info () { return }
}

export namespace has {
  export const info   = ():boolean=> File.exists(Package.paths.json)
  export const module = ():boolean=> Dir.exists(paths.tool)

  // FIX: Separate into dependencies and module
  export function requirements () :boolean {
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
    return JSON.parse(File.read(Package.paths.json).toString()) as cfg.Package.Info
  }
} //:: confy.Package.get


export async function init () :Promise<void> {
  if (!Package.has.requirements()) await Package.create.requirements()
  const pkg = Package.get.info()
  if (pkg.name === "confy") return
  // FIX: Package.create.info()
} //:: confy.Package.init

} //:: confy.Package

