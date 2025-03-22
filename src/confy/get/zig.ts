//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import { info, fail } from "@confy/log";
import { File, Shuffle } from "@confy/tools";
import { cfg as confy } from '@confy/cfg'
import Minisign from '@confy/tools/minisign'

namespace Zig {
  export function TODO (msg :string) { throw new Error("TODO: "+msg) }
  export const confyMarker :string= confy.tool.name
  export const confySource :string= "?source="+Zig.confyMarker
  export namespace minisign {
    const extension = ".minisig"
    export const remote = "https://ziglang.org/builds/"
    export function suffixed (url :URL) :URL { return new URL(url.toString()+extension)}
    export function remap (url :URL) :URL { return new URL(url.toString())}
    /**
     * @description
     * Upstream's minisign key, from https://ziglang.org/download
     * */
    export const Key = "RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U"

    /**
     * @description
     * Validates the given {@param V} version using the official upstream's minisign key.
     * */
    export function valid (
        sig  : ArrayBufferLike,
        data : ArrayBufferLike,
      ) :boolean {
      const mKey = Minisign.parseKey(Zig.minisign.Key)
      const mSig = Minisign.parseSignature(sig)
      return Minisign.verifySignature(mKey, mSig, data)
    }
  }
  export function tagURL (url :URL) :URL { url.searchParams.set("source", Zig.confyMarker); return url }

  type Hash = string
  export type File = {
    shasum       :Hash
    size         :number
    tarball      :URL
    zigTarball  ?:URL  // Link to the official upstream file. Available only in some mirrors.
  }

  type Files = {
    [key :string] :Zig.File
  }
  export type Version = {
    version  ?:string  // Only for master
    date      :string
    docs      :URL
    stdDocs   :URL
    notes     :URL
  } & Files

  export type Registry = Record<string, Version>
  export type Mirror = {
    url    :URL
    index  :Zig.Registry
  }
} //:: Zig

export const getZig = {
  /** @warning Will fail when cfg.zig.systemBin is on */
  exists: (
    cfg: confy.Config = confy.defaults.clone()
  ) :boolean=> /* FIX: */ File.exists((cfg.zig.systemBin) ? cfg.zig.name : cfg.zig.bin),

  mirrors : {
    url      : new URL("https://raw.githubusercontent.com/mlugg/setup-zig/refs/heads/main/mirrors.json"),
    get      : async() :Promise<[URL, string]>=> await (await fetch(getZig.mirrors.url)).json() as any,
    list     : async() :Promise<URL[]>=> Shuffle.FisherYates((await getZig.mirrors.get()).map((a:any) => a[0])),
    official : new URL("https://ziglang.org/download/index.json"),

    /**
     * @description
     * Downloads the given {@param file} from the first available mirror.
     * Process:
     * 1. Try every mirror tracked by mlugg/setup-zig
     * 2. Use the official mirror if all others fail
     * @returns An object containing the `{URL,Response}` of the first random server that responded.
     * */
    search: async(file :string) => {
      for (const url of await getZig.mirrors.list()) {
        try   { return {url:url, response: await fetch(Zig.tagURL(new URL(url.toString()+file)))} }
        catch { continue }
      }
      return {url: getZig.mirrors.official, response: await fetch(Zig.tagURL(new URL(getZig.mirrors.official.toString()+file)))}
    },
  },

  json: {
    /**
     * @description
     * Downloads the Zig index.json data from the first available mirror.
     * Process:
     * 1. Try every mirror tracked by mlugg/setup-zig
     * 2. Use the official mirror if all others fail
     * */
    download: async() :Promise<Zig.Mirror>=> {
      const mirror = await getZig.mirrors.search("/index.json")
      return {url: mirror.url, index: await mirror.response.json() as any}
    },
  },

  data: {
    download: async (
        vers : Zig.Version,
        file : Zig.File,
        trg  : fs.PathLike
      ) :Promise<void>=> {
      const url_sig = Zig.minisign.suffixed(file.tarball)
      Zig.tagURL(url_sig)
      const sig  :Buffer= await File.download(url_sig.toString())
      const data :Buffer= await File.download(file.tarball.toString(), trg.toString())
      if (!Zig.minisign.valid(sig.buffer, data.buffer)) fail(`Zig: Failed to download version \`${vers.version}\` from ${file.tarball}. Couldn't validate the signature of the tarball downloaded at:`, trg.toString())
    },
  },

  /**
   * @description
   * Downloads the Zig version described in {@param cfg}.zig.
   * Will not do anything if the target already exists.
   * Will unzip when the release file already exists in the cache.
   * Will download and unzip when the file does not exist in the cache.
   *
   * @todo Auto-download new release when available.
   *
   * @param cfg The confy.Config object where the zig configuration options will be accessed from.
   * @param force Download/unzip the file even if it already exists.
   * */
  download: async(
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<void>=> {
    // Skip repeating downloads
    if (getZig.exists(cfg) && !force) { if (cfg.verbose) { info("Zig: Already exists. Omitting download.") }; return }
    if (cfg.verbose && force) info("Force downloading Zig into folder: ", cfg.zig.dir)
    else if (cfg.verbose)     info("Zig: Does not exist. Downloading into folder: ", cfg.zig.dir)

    // Download the Index
    const { url, index } = await getZig.json.download()
    if (cfg.verbose) info("Zig: Downloaded index from: ", url)
    if (cfg.verbose) info("Zig: Writing index to: ", cfg.zig.index)
    File.write(cfg.zig.index, JSON.stringify(index, null, 2))

    // Manage current version
    const vers :string= (cfg.zig.version === confy.NamedVersion.latest)
      ? Object.keys(index)[1]!
      : cfg.zig.version.toString()
    const zig :Zig.Version|undefined= index[vers]
    if (zig == undefined) fail(`Zig Download: Couldn't find version \`${vers}\` in the registry hosted at:  ${url}`)
    if (cfg.verbose) info("Zig: Writing current version index to: ", cfg.zig.current)
    zig!.version ??= vers
    File.write(cfg.zig.current, JSON.stringify(zig, null, 2))

    info(`Zig: Downloading \`${vers}\` to: `, cfg.zig.dir)
    // const url_sig = Zig.minisign.suffixed(zig[""].tarball).searchParams.set("source", "confy")
  }
}

