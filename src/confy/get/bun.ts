//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as os from 'node:os'
// @deps confy
import { info } from '@confy/log'
import { gh } from "@confy/tools/git"
import { File, Dir, Path } from '@confy/tools/files'

function TODO (msg :string) { throw new Error("TODO: "+msg) }

export const getBun = {
  exists: ()=> TODO("get.Bun.exists is not implemented."), // FIX: TODO

  target :():string=>{ return `bun-${os.platform()}-${os.arch()}` },
  zip    :():string=>{ return `${getBun.target()}.zip` },

  release: async()=> {
    const request = await gh.rest.repos.getLatestRelease({owner: "oven-sh", repo: "bun"})
    return request.data.assets.find((val) => { return (val.name === getBun.zip()) ? val : undefined })
  },

  /**
   * @description
   * Downloads Bun to {@param trg}.
   * Will not do anything if the target already exists.
   * Will unzip when the release file already exists in the cache.
   * Will download and unzip when the file does not exist in the cache.
   *
   * @todo Auto-download new release when available.
   * @param force Download/unzip the file even if it already exists.
   * */
  download: async(trg :string, force = false)=> {
    if (File.exists(trg) && !force) return
    info("Downloading Bun to: ", trg)
    const dir = Path.dirname(trg)+"/"
    const dlDir = Dir.cwd()+"/bin/.cache/confy/download/"
    const zip = dlDir+getBun.zip()
    // Download
    const url = (await getBun.release())?.browser_download_url ?? ""
    if ( File.exists(zip) && force) File.rmv(zip)
    if (!File.exists(zip) || force) await File.download(url, dlDir)
    // Unzip
    let zipTrg :string= ""
    await File.unzip(zip, {dir: dlDir, onEntry: (entry:any)=> { if (entry.fileName.endsWith("/bun")) {
      zipTrg = dlDir+entry.fileName
    } }})
    // Move to the Destination and Cleanup
    File.move(zipTrg, dir+"bun")
    Path.rm(Path.dirname(zipTrg))
    info("Done downloading Bun.")
  }
}

