//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
//! @fileoverview Tools for Package Management
//_____________________________________________|
import { Manager } from '@confy/manager'
import { File } from '@confy/tools/files'
import { cfg as confy } from './cfg'

const cfg = confy.defaults.clone()

export namespace Package {
  export type Info = any

  export namespace files {
    export const info = "package.json"
  }

  export namespace has {
    export function info() :boolean { return File.exists(Package.files.info) }
  }

  export namespace get {
    export async function info() :Promise<Info> {
      return await JSON.parse(JSON.stringify(File.read(Package.files.info))) as Package.Info
    }
  }

  export async function init() :Promise<void> {
    if (Package.has.info()) return  // FIX: Should check if Package.info has the dependencies instead
    const pkg = await Package.get.info()
    if (pkg.name === "confy") return
    await Manager.Bun.run(cfg, "add", "confy")
    await Manager.Bun.run(cfg, "install")
  }
}

