//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
import * as path from 'path'
import { Readable } from 'stream'
// @deps lib
import extract from 'extract-zip'
import * as tar from 'tar'
import * as XZ from 'xz-decompress'
// @deps confy
import { Default as log } from '@confy/log'
import { pathToFileURL } from 'url'


export const Path = {
  ext      : (P :fs.PathLike) :string=> path.extname(P.toString()),
  basename : (P :fs.PathLike, ext ?:fs.PathLike) :fs.PathLike=> path.basename(P.toString(), (ext) ? ext.toString() : undefined),
  dirname  : (P :fs.PathLike) :fs.PathLike=> path.dirname(P.toString()),
  exists   : (path :fs.PathLike) :boolean => { return fs.existsSync(path) },
  rm       : (path :fs.PathLike) => (Path.exists(path)) ? fs.rm(path, () => {}) : {},
  join     : (...paths:fs.PathLike[]) :fs.PathLike=> path.join(...paths.flatMap(a => a.toString())),

  /**
   * @description
   * Return the basename of the {@param P} path without its extension.
   * Removes whatever extension would be returned by {@link path.extname}
   * */
  name: (P :fs.PathLike) :fs.PathLike=> path.basename(P.toString(), path.extname(P.toString())),

  /**
   * @description
   * Converts the varargs {@param paths} to an absolute path based on the current working directory.
   * All arguments will be used as subpaths in the order that they are given.
   *
   * @example
   * ```ts
   * const result = Path.toAbsolute("thing", "other", "end")
   * console.log(process.cwd())  //   /root/path
   * console.log(result)         //   /root/path/thing/other/end
   * ```
   *
   * @note
   * There will always be an implicit `process.cwd()` at the start.
   *
   * Use {@link path.resolve} to solve non-cwd paths.
   * */
  toAbsolute: (...paths :fs.PathLike[]) :fs.PathLike=> path.resolve(process.cwd(), ...paths.map((p)=>p.toString())),
} //:: Path


export const Dir = {
  exists : Path.exists,
  rmv    : (path :fs.PathLike) => (Dir.exists(path)) ? fs.rmdir(path, () => {}) : {},
  cwd    : () :fs.PathLike => { return process.cwd() },
  create : (trg :fs.PathLike, recursive :boolean= true) => fs.mkdirSync(trg, {recursive: recursive}),
  move   : (src :fs.PathLike, trg :fs.PathLike, opts ?:fs.CopySyncOptions) => {
    fs.cpSync(src.toString(), trg.toString(), {...opts, recursive: true})
    Dir.rmv(src)
  },
} //:: Dir


export const File = {
  exists   : Path.exists,
  rmv      : Path.rm,
  read     : fs.readFileSync,
  cp       : fs.copyFileSync,
  cpy      : fs.copyFileSync,

  /**
   * @description
   * Creates the file at {@param trg} if it doesn't already exist.
   * Does nothing if it does.
   * */
  create: (trg: fs.PathLike) :void=> { Dir.create(Path.dirname(trg.toString())); fs.closeSync(fs.openSync(trg, 'a')) },

  /**
   * @description
   * Type Wrapper for {@link extract-zip}/extract
   * */
  unzip: async(trg :fs.PathLike, opts :extract.Options) :Promise<void>=> extract(trg.toString(), opts),

  /**
   * @description
   * Wrapper for {@link tar}/extract
   * @param src (ergonomics/clarity) Overrides opts.f when passed as a non-nullish value
   * @param dir (ergonomics/clarity) Folder where the contents will be extracted to. Overrides opts.C when passed
   * */
  untar: async(
      src   : fs.PathLike,
      dir   : fs.PathLike,
      opts  : tar.TarOptionsWithAliasesAsyncFile,
    ) :Promise<void>=> tar.extract({...opts, f: src ?? opts.f, C: dir ?? opts.C} as tar.TarOptionsWithAliasesAsyncFile),

  /**
   * @description
   * Reads the data at {@param src}, decompresses it, and extracts its contents to the {@param trg} folder
   * Assumes that the file stored at `src` contains data compressed/archived as lzma/XZ _(ie: .tar.xz)_
   * eg: If `src` is `path/file.tar.xz` file, its contents will be extracted to trg/*
   *
   * @param src Overrides opts.f when passed as a non-nullish value when unarchiving from `@param tmp`
   * @param dir Folder where the contents will be extracted to. When passed, it overrides opts.C when unarchiving from `@param tmp`
   * @param tmp Path where the `.tar` data will be decompressed into. Will be passed as input to {@link File.untar}
   * @param clean Removes the temporary file at {@param tmp} when done unarchiving
   * @param opts Options forwarded to {@link File.untar}
   * */
  untarxz: async(
      src   : fs.PathLike,
      dir   : fs.PathLike,
      tmp   : fs.PathLike,
      clean : boolean = true,
      opts  = {} as tar.TarOptionsWithAliasesAsyncFile,
    ) :Promise<void>=> {
    log.verb("Decompressing XZ file: ", src, " -> ", tmp)
    await File.lzma.decompress(src, tmp)
    log.verb("Done decompressing: ", src)
    log.verb("Extracting tar file: ", tmp,  " -> ", dir)
    await File.untar(tmp, dir, opts)
    log.verb("Done extracting: ", tmp)
    if (clean) File.rmv(tmp)
  },


  lzma: {
    /**
     * @description
     * Wrapper for {@link lzma}/decompress
     * Reads the data at {@param src}, decompresses it, and outputs the result to {@param trg}
     * eg: If `src` was a .tar.xz file, the result will be a .tar file.
     * */
    decompress: async(
        src : fs.PathLike,
        trg : fs.PathLike,
      ) :Promise<void>=> {
      const data   = await fetch(pathToFileURL(src.toString()))
      const stream = new XZ.XzReadableStream(data.body!)
      const view = new DataView(await new Response(stream).arrayBuffer())
      File.write(trg, view)
    },
  },

  /**
   * @description
   * Writes all bytes of {@param data} into {@param trg}.
   * Creates the container folders recursively when they do not exist.
   * */
  write: function(
      trg    :fs.PathLike,
      data   :string|NodeJS.ArrayBufferView,
      opts  ?:fs.WriteFileOptions
    ) :void {
    const dir = Path.dirname(trg.toString())
    if (!Path.exists(dir)) Dir.create(dir)
    fs.writeFileSync(trg, data, opts)
  }, //:: File.write

  /**
   * @description
   * Moves {@param src} to {@param trg} by copying src to trg and removing trg on completion.
   * */
  move: function(
      src   :fs.PathLike,
      trg   :fs.PathLike,
      mode ?:number
    ) :void {
    fs.copyFileSync(src as string, trg as string, mode)
    Path.rm(src)
  }, //:: File.move

  /**
   * @description
   * Downloads the file hosted at {@param url} into the {@param trg} file.
   * @note Folders will return their index route.
   * @throws Error on when the remote request for data fails.
   * */
  download : file_download_fromURL,
  dl: {
    /**
     * @description
     * Downloads the file hosted at the url of the {@param R} Response into the {@param trg} file.
     * @note Folders will return their index route.
     * */
    fromResponse : async(R :Response, trg :fs.PathLike) :Promise<void>=> await fs.promises.writeFile(trg, Readable.fromWeb(R.body ?? {} as any)),
    fromURL      : file_download_fromURL,
  }, //:: File.dl
} //:: File

async function file_download_fromURL (url :URL, trg :fs.PathLike) :Promise<void> {
  const R = await fetch(url)
  if (!R.ok) log.fail("File.download: Tried to download a file, but failed to request its data.", JSON.stringify({url, trg, R}, null,  2))
  await File.dl.fromResponse(R, trg)
}

