//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
import * as std_os from 'node:os'
import { ok } from 'assert'
// @deps confy
import * as log from "../log";
import { cfg as confy } from '../cfg'
import { Dir, File, Path, Shuffle } from "../tools"
import Minisign from '../tools/minisign'
export namespace Zig {


//______________________________________
// @section Generic Zig config
//____________________________
export const name               = "zig"
export const indexFile          = "index.json"
export const InvalidVersionName = "InvalidVersionName"
export const InvalidVersionFile = "InvalidVersionFile.txt"
export const InvalidTarballFile = "InvalidTarballFile.txt"


//______________________________________
// @section Minisign Tools
//____________________________
export namespace minisign {
  export const extension = ".minisig"

  /**
   * @description
   * Upstream's minisign key, from https://ziglang.org/download
   * */
  export const Key = "RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U"

  /**
   * @description
   * Validates the given {@param data} with the signature at {@param sig} using the official upstream's minisign key.
   * */
  export function valid (
      sig  : Buffer<ArrayBufferLike>,
      data : Buffer<ArrayBufferLike>,
    ) :boolean {
    const mKey = Minisign.parseKey(Zig.minisign.Key)
    const mSig = Minisign.parseSignature(sig)
    return Minisign.verifySignature(mKey, mSig, data)
  }
} //:: Zig.minisign


//______________________________________
// @section Mirror Management Tools
//____________________________
export namespace mirrors {
  export const registry = {
    url : new URL("https://raw.githubusercontent.com/mlugg/setup-zig/refs/heads/main/mirrors.json"),
    get : async() :Promise<[URL, string]>=> await (await fetch(Zig.mirrors.registry.url)).json() as any,  // eslint-disable-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-explicit-any
  }

  export namespace official {
   export const base      = () :URL=> new URL("https://ziglang.org")
   export const builds    = () :URL=> new URL("builds",    Zig.mirrors.official.base())
   export const downloads = () :URL=> new URL("download",  Zig.mirrors.official.base())
   export const index     = () :URL=> new URL(Path.join(Zig.mirrors.official.downloads().toString(), "index.json").toString())
  }

  export async function list () :Promise<URL[]> {
    const result = Shuffle.FisherYates((await Zig.mirrors.registry.get()).map((a:any) => a[0]))    // eslint-disable-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-member-access
    result.push(Zig.mirrors.official.downloads())
    return result as URL[]
  }
}

//______________________________________
// @section File Tools
//____________________________
/** @warning Will fail when cfg.zig.systemBin is on */
export const exists = (
  cfg: confy.Config = confy.defaults.clone()
) :boolean=> /* FIX: */ File.exists((cfg.zig.systemBin) ? cfg.zig.name : cfg.zig.bin)

/**
 * @description
 * Generic file cleaning with logging and config options.
 * */
export function clean (
    trg   : fs.PathLike,
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false,
  ) :void {
  if (!Path.exists(trg)) return
  if (!force) return log.verb(cfg, `Zig: ${trg.toString()} Already exists. Not cleaning.`)
  log.verb(cfg, "Zig: Cleaning path:", trg)
  try   { File.rmv(trg) }
  catch {  Dir.rmv(trg) }
}



//______________________________________
// @section Data Indexing Types
//____________________________
type Hash = string
export type FileID = string
export type File = {
  shasum       :Hash
  size         :number
  tarball      :URL
  zigTarball  ?:URL  // Link to the official upstream file. Available only in some mirrors.
}

type Files = Record<Zig.FileID, Zig.File>
export type Version = {
  version  ?:string  // Only for master
  date      :string
  docs      :URL
  stdDocs   :URL
  notes     :URL
} & Files

export type Registry = Record<string, Zig.Version>


//______________________________________
// @section Host System/Tar Name Resolution Tools
//____________________________
export namespace Host {
  /**
   * @description
   * Maps the result of calling {@link std_os.arch} into the string value expected by Zig for the CPU target (aka arch).
   * */
  enum Cpu {
    arm      = 'armv7a',
    arm64    = 'aarch64',
    loong64  = 'loongarch64',
    mips     = 'mips',
    mipsel   = 'mipsel',
    mips64   = 'mips64',
    mips64el = 'mips64el',
    ppc64BE  = 'powerpc64',  // @warning Endinaness is lost on this platform.
    ppc64LE  = 'powerpc64le',
    riscv64  = 'riscv64',
    s390x    = 's390x',
    ia32     = 'x86',
    x64      = 'x86_64',
  }; type CpuKey = keyof typeof Cpu
  /**
   * @description
   * Returns the CPU target name of the current host system translated to Zig naming convention.
   * */
  export function cpu () :string {
    switch(std_os.arch()) {
      case "powerpc64" : return Cpu[std_os.arch()+(std_os.endianness()) as CpuKey]
      default          : return Cpu[std_os.arch() as CpuKey]
    }
  }

  /**
   * @description
   * Maps the result of calling {@link std_os.platform} into the string value expected by Zig for the OS target.
   * */
  enum Os {
    aix     = 'aix',
    android = 'android',
    freebsd = 'freebsd',
    linux   = 'linux',
    darwin  = 'macos',
    openbsd = 'openbsd',
    sunos   = 'solaris',
    win32   = 'windows',
  }; type OsKey = keyof typeof Os
  /**
   * @description
   * Returns the OS target name of the current host system translated to Zig naming convention.
   * */
  export function os () :string { return Os[std_os.platform() as OsKey] }

  /**
   * @description
   * Returns the CPU-OS target name for finding the tarball for the current system.
   * */
  export function target () :string { return `${Zig.Host.cpu()}-${Zig.Host.os()}` }
}

export namespace Tar {
  export function extFor (os :NodeJS.Platform) :string { switch(os) {
    case "win32" : return ".zip"
    default      : return ".tar.xz"
  }}

  export function ext () :string { return Zig.Tar.extFor(std_os.platform()) }

  /**
   * @description
   * Returns the basename (without extension) of the Zig tarball targetting the current System for version {@arg vers}.
   * @warning Assumes the `vers.version` field is not undefined, and a valid version for master versions.
   * */
  export function name (vers :string) :string { return `${Zig.name}-${Zig.Host.os()}-${Zig.Host.cpu()}-${vers}` }

  /**
   * @description
   * Returns the filename of the Zig tarball targetting the current System for version {@arg vers}.
   * @warning Assumes the `vers.version` field is not undefined, and a valid version for master versions.
   * */
  export function filename (vers :string) :fs.PathLike { return `${Zig.Tar.name(vers)}${Zig.Tar.ext()}`}
}


//______________________________________
// @section Data Download Tools
//____________________________
export namespace Download {
  export const confyMarker :string= confy.tool.name
  export const tagURL = (url :URL) :URL=> { url.searchParams.set("source", Zig.Download.confyMarker); return url }


  /**
   * @description
   * Returns whether or not we should skip downloading Zig, based on the given {@param cfg}
   * Removing index.json, current.json, the cache folder or the .tar file for the current host will all trigger a redownload
   * Will never skip when {@param force} is true
   * */
  export function skip (
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :boolean {
    if (force) return false
    const binExists = Zig.exists(cfg)
    if (binExists) { log.verb(cfg, "Zig: Already exists. Omitting download."); return true }
    if (!File.exists(cfg.zig.index   )) { log.verb(cfg, `Zig: Index at ${cfg.zig.index.toString()} does not exist. Downloading Zig.`); return false }
    if (!File.exists(cfg.zig.current )) { log.verb(cfg, `Zig: Current version index at ${cfg.zig.current.toString()} does not exist. Downloading Zig.`); return false }
    if (!File.exists(cfg.zig.cache   )) { log.verb(cfg, `Zig: Cache folder at ${cfg.zig.cache.toString()} does not exist. Downloading Zig.`); return false }
    const version = JSON.parse(File.read(cfg.zig.current).toString()) as Zig.Version
    const tarName = Zig.Tar.filename(version.version ?? Zig.InvalidVersionName)
    const tarPath = Path.join(cfg.zig.cache, tarName)
    if (!File.exists(tarPath)) { log.verb(cfg, `Zig: Tarball at ${tarPath.toString()} does not exist. Downloading Zig.`); return false }
    // All conditions for skipping a download matched. Return true
    return true
  }

  /**
   * @description
   * Generic request for a file from a Zig mirror with logging configuration options
   * @returns The Response from the server for that file.
   * */
  export async function request (
      url   : URL,
      cfg   : confy.Config = confy.defaults.clone(),
    ) :Promise<Response> {
    // Download
    log.verb(cfg, "Zig: Requesting ", url.toString(), " ...")
    const mirror = await fetch(Zig.Download.tagURL(url))
    const file = Path.basename(url.pathname)
    if (!mirror.ok) log.fail(cfg, `Zig: Something went wrong when downloading ${file.toString()} from: `, mirror.url.toString())
    // Return the response
    log.verb(cfg, "Zig: Done requesting url: ", mirror.url.toString())
    return mirror
  }


  export namespace current {
    export function get (
        index : Zig.Registry,
        vers  : string,
        cfg   : confy.Config = confy.defaults.clone(),
      ) :Zig.Version {
      const result = index[vers]
      if (!result) log.fail(cfg, `Zig: Failed to find version \`${vers}\` inside index. Data: `, JSON.stringify(index, null, 2))
      ok(result)
      return result
    }

    export function write (
        index : Zig.Registry,
        vers  : string,
        cfg   : confy.Config = confy.defaults.clone(),
        force : boolean      = false,
      ) :Zig.Version {
      // Clean when needed
      Zig.clean(cfg.zig.current, cfg, force)
      // Write and Return the version's data
      const data = Zig.Download.current.get(index, vers)
      if (!File.exists(cfg.zig.current)) File.write(cfg.zig.current, JSON.stringify(data, null, 2))
      return data
    }
  }
 
  /**
   * @description
   * Downloads the {@param cfg}.zig.index file from the given mirror at {@param url}
   * It won't download Zig if it already exists and {@param force} is false
   * */
  export async function index (
      url   : URL,
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<Zig.Registry> {
    // Clean when needed
    Zig.clean(cfg.zig.index, cfg, force)
    // Dont download if it still exists, just read
    if (File.exists(cfg.zig.index)) return JSON.parse(File.read(cfg.zig.index).toString()) as Zig.Registry
    // Request & Download
    const trg = new URL(Path.join(url, Zig.indexFile).toString())
    const mirror = await Zig.Download.request(trg, cfg)
    log.verb(cfg, "Zig: Starting Download: ", Path.basename(cfg.zig.index), " from: ", mirror.url)
    await File.dl.fromResponse(mirror, cfg.zig.index)
    // Return the downloaded index object
    log.verb(cfg, "Zig: Done downloading: ", Path.basename(cfg.zig.index), "from: ", mirror.url)
    return JSON.parse(File.read(cfg.zig.index).toString()) as Zig.Registry
  }

  /**
   * @description Returns the URL of the tarball targetting version {@param vers}
   * */
  export function tarURL (
      index : Zig.Registry,
      vers  : string,
      cfg   : confy.Config = confy.defaults.clone(),
    ) :URL {
    const version = Zig.Download.current.get(index, vers)
    const host    = Zig.Host.target()
    const file    = version[host]
    if (!file) log.fail(cfg, `Zig: Failed to find file for host \`${host}\` inside index. Data: `, JSON.stringify(version, null, 2))
    ok(file)
    return new URL(file.tarball.toString())
  }

  export function tarFilename (
      index : Zig.Registry,
      vers  : string,
      cfg   : confy.Config = confy.defaults.clone(),
    ) :fs.PathLike { return Path.basename(Zig.Download.tarURL(index, vers, cfg)) }


  /**
   * @private
   * Internal use only. Duplicate logic for downloading tarball or its signature from one function.
   * Allows cleanup/download of each file individually without duplicate logic.
   * */
  async function SigOrTar (
      isSig : boolean,
      index : Zig.Registry,
      vers  : string,
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<Buffer<ArrayBufferLike>> {
    // Figure out where we download to/from
    const url = Zig.Download.tarURL(index, vers, cfg)
    if (isSig) url.href += Zig.minisign.extension
    const trgFile = Path.join(cfg.zig.cache, Path.basename(url))
    // Clean when needed
    Zig.clean(trgFile, cfg, force)
    // Download the file
    const mirror = await Zig.Download.request(url, cfg)
    log.verb(cfg, "Zig: Starting Download:", Path.basename(trgFile), " from: ", mirror.url)
    await File.dl.fromResponse(mirror, trgFile)
    // Read and Return the file's data
    log.verb(cfg, "Zig: Done downloading: ", Path.basename(trgFile), "from: ", mirror.url)
    return Buffer.from(File.read(trgFile).buffer)
  }

  export async function sig (
      index : Zig.Registry,
      vers  : string,
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<Buffer<ArrayBufferLike>> { return SigOrTar(/*isSig*/ true, index, vers, cfg, force) }

  export async function tar (
      index : Zig.Registry,
      vers  : string,
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<Buffer<ArrayBufferLike>> { return SigOrTar(/*isSig*/ false, index, vers, cfg, force) }

 /**
   * @description
   * Downloads Zig from the given mirror at {@param url}
   * Will always download the index.json from the mirror, even if {@param force} is true
   * Will skip downloading the tarball from the mirror when it already exists {@param force} is false
   * */
  export async function from (
      url   : URL,
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<fs.PathLike> {
    // Download the Index
    const index = await Zig.Download.index(url, cfg, true) // Always redownload the index internally
    const vers :string= (cfg.zig.version === confy.Version.Named.latest)
      ? Object.keys(index)[1] as string
      : cfg.zig.version.toString()
    Zig.Download.current.write(index, vers, cfg, true) // Always rewrite the current index internally
    // Download the tarball
    const sig = await Zig.Download.sig(index, vers, cfg, force)
    const tar = await Zig.Download.tar(index, vers, cfg, force)
    // Validate the tarball
    const valid = Zig.minisign.valid(sig, tar)
    if (!valid) log.fail(cfg, `Zig: Couldn't validate the tarball's signature:`)
    // Validate the tarball
    return Path.join(cfg.zig.cache, Zig.Download.tarFilename(index, vers, cfg))
  }


  export async function tryAll (
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<fs.PathLike> {
    if (Zig.Download.skip(cfg, force)) return Zig.InvalidTarballFile
    Zig.clean(cfg.zig.dir, cfg, force)
    Zig.clean(cfg.zig.cache, cfg, force)
    if (!Dir.exists(cfg.zig.cache)) Dir.create(cfg.zig.cache)

    // For every mirror, with official last
    const mirrors = await Zig.mirrors.list()

    let result :fs.PathLike= Zig.InvalidVersionFile
    for (let id = 0; id < mirrors.length; ++id) {
      const mirror = mirrors[id]; ok(mirror)
      try {
        result = await Zig.Download.from(mirror, cfg, force)
        break; // mirror.ok
      } catch (e) { // Mirror failed. Try next
        const next = mirrors[id+1]
        // FIX: Something is very off with these messages. The current/next values are mixed up by the try/catch scopes
        if (next) log.verb(cfg, (e as Error).message, `\n -> Downloading from \`${mirror.toString()}\` didn't work. Re-trying from: ${next.toString()}`)
        else      log.fail(cfg, "Zig: Something went wrong when downloading. No link worked, even the official one. Links tried (in order):", JSON.stringify({ mirrors }, null, 2))
      }
    }
    return result
  }
}


export async function extract (
    trg   : fs.PathLike,
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false,
  ) :Promise<void> {
  // Clean the target folder when needed
  Zig.clean(cfg.zig.dir, cfg, force)
  // Extract into the zig cache
  log.verb(cfg, "Zig: Extracting binaries into folder: ", cfg.zig.cache)
  const trgDir  = Path.toAbsolute(cfg.zig.cache)
  const subDir  = Path.join(cfg.zig.cache, Path.basename(trg, Zig.Tar.ext()))  // Subfolder where the files will exist after extract
  const tarFile = Path.join(cfg.zig.cache, Path.basename(trg, ".xz"))
  try { switch (Zig.Tar.ext()) {
    case ".zip"    : await File.unzip(trg, {dir: trgDir.toString() }); break;
    case ".tar.xz" : await File.untarxz(trg, cfg.zig.cache, tarFile, {clean: true, verbose: cfg.verbose} as any); break;   // eslint-disable-line @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-argument
  }} catch (e) {
    log.fail(cfg, (e as Error).message, "\n -> Extracting tarball failed.")
  }
  // Move the cache data into the target folder
  Dir.move(subDir, cfg.zig.dir)
} //:: Zig.unzip


//______________________________________
// @section Download Tools
//____________________________
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
export async function download (
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false,
  ) :Promise<void> {
  if (Zig.exists(cfg) && !force) return log.verb(cfg, "Zig: Already exists. Omitting download.");
  // Skip repeating downloads
  if (force) log.verb(cfg, "Zig: Force downloading into folder: ", cfg.zig.dir)
  else       log.verb(cfg, "Zig: Does not exist. Downloading into folder: ", cfg.zig.dir)
  const trg = await Zig.Download.tryAll(cfg, force)
  await Zig.extract(trg, cfg, force)
} //:: Zig.download

} //:: Zig

// Alternative export
export const getZig = {
  exists   : Zig.exists,
  download : Zig.download,
  extract  : Zig.extract,
}

