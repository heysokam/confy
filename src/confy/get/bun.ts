//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as os from 'node:os'
// @deps confy
import * as log from '@confy/log'
import { cfg as confy } from '@confy/cfg'
import { gh } from "@confy/tools/git"
import { File, Path, Dir } from '@confy/tools/files'
const InvalidURL = "BadURL"
export namespace BUN {


export const name = "bun"
export function TODO (msg :string) { throw new Error("Bun: TODO: "+msg) }

/** @warning Will fail when cfg.bun.systemBin is on */
export const exists = (
  cfg: confy.Config = confy.defaults.clone()
) :boolean=> /* FIX: */ File.exists((cfg.bun.systemBin) ? cfg.bun.name : cfg.bun.bin)


export function target () :string { return `bun-${os.platform()}-${os.arch()}` }
export function zip    () :string { return `${BUN.target()}.zip` }
export async function release () {
  const request = await gh.rest.repos.getLatestRelease({owner: "oven-sh", repo: "bun"})
  return request.data.assets.find((val) => { return (val.name === getBun.zip()) ? val : undefined })
} //:: BUN.release


/**
 * @description
 * Downloads Bun to {@param trg}.
 * Will not do anything if the target already exists.
 * Will unzip when the release file already exists in the cache.
 * Will download and unzip when the file does not exist in the cache.
 *
 * @todo Explicit Bun version.
 * @todo Auto-download new release when available.
 *
 * @param force Download/unzip the file even if it already exists.
 * */
export async function download (
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false
  ) :Promise<void> {
  // Skip repeating downloads
  if (BUN.exists(cfg) && !force) return log.verb(cfg, "Bun: Already exists. Omitting download.")
  if (force) log.verb(cfg, "Bun: Force downloading into folder: ", cfg.bun.dir)
  else       log.verb(cfg, "Bun: Does not exist. Downloading into folder: ", cfg.bun.dir)

  // Download the Index
  // Manage current version
  const url = new URL((await getBun.release())?.browser_download_url ?? InvalidURL)
  // Download the Release
  log.info(cfg, "Bun: Downloading to: ", cfg.bun.bin)
  const zip = Path.toAbsolute(Path.join(cfg.bun.cache, getBun.zip()))
  if ( File.exists(zip) && force) File.rmv(zip)
  if (!File.exists(zip)) Dir.create(Path.dirname(zip))
  if (!File.exists(zip)) await File.download(url, zip)

  // Unzip
  let zipTrg :string= ""
  await File.unzip(zip, {dir: Path.toAbsolute(cfg.bun.cache).toString(), onEntry: (entry:any)=> { if (Path.name(entry.fileName).toString().endsWith(BUN.name)) {
    zipTrg = Path.join(cfg.bun.cache, entry.fileName).toString()
  }}})

  // Move to the Destination and Cleanup
  if (!Dir.exists(cfg.bun.dir)) Dir.create(cfg.bun.dir)
  File.move(zipTrg, cfg.bun.bin+Path.ext(zipTrg))
  Path.rm(Path.dirname(zipTrg))
  log.info(cfg, "Done downloading Bun.")
} //:: BUN.download
} //:: BUN


// Alternative export
export const getBun = {
  exists  : BUN.exists,
  target  : BUN.target,
  zip     : BUN.zip,
  release : BUN.release,
  download: BUN.download,
}

