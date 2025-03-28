//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Tools for Package Management
//_____________________________________________|
import { Manager } from './manager'
import { File } from './tools/files'
import { cfg } from './cfg'
const confy = cfg.defaults.clone()
export namespace Package {


export namespace files {
  export const json = "package.json"
} //:: confy.Package.files

export namespace create {
  export function info (){}
  export async function requirements () :Promise<void>{
    await Manager.Bun.run(confy, "add", cfg.tool.name)
  }
}

export namespace has {
  export const info = ():boolean=> File.exists(Package.files.json)


  // FIX: Should check if Package.info has the dependencies
  export function requirements () :boolean {
    if (!Package.has.info()) return false
    const json = Package.get.info()
    return cfg.tool.pkgName in json.dependencies
  }
} //:: confy.Package.has


export namespace get {
  export function info() :cfg.Package.Info {
    return JSON.parse(File.read(Package.files.json).toString()) as cfg.Package.Info
  }
} //:: confy.Package.get


export async function init () :Promise<void> {
  if (!Package.has.requirements()) Package.create.info()
  const pkg = Package.get.info()
  if (pkg.name === "confy") return
  await Package.create.requirements()
  await Manager.Bun.run(confy, "install")
} //:: confy.Package.init

} //:: confy.Package

