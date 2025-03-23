//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
import * as path from 'path'
import { Readable } from 'stream'
// @deps lib
import extract from 'extract-zip'
// @deps confy
import { fail } from '@confy/log'

export const Path = {
  basename : path.basename,
  dirname  : path.dirname,
  ext      : path.extname,

  exists : (path :fs.PathLike) :boolean => { return fs.existsSync(path) },
  rm     : (path :fs.PathLike) => { fs.rm(path, () => {}) },
  join   : (...paths:fs.PathLike[]) :fs.PathLike=> path.join(...paths.flatMap(a => a.toString())),

  /**
   * @description
   * Return the basename of the {@param P} path without its extension.
   * Removes whatever extension would be returned by {@link path.extname}
   * */
  name: (P :fs.PathLike) :fs.PathLike=> path.basename(P.toString(), path.extname(P.toString())),

}

export const Dir = {
  exists : Path.exists,
  cwd    : () :fs.PathLike => { return process.cwd() },
  move   : (src :fs.PathLike, trg :fs.PathLike) => fs.cpSync(src as string, trg as string),
  create : (trg :fs.PathLike, recursive :boolean= true) => fs.mkdirSync(trg, {recursive: recursive}),
}

export const File = {
  exists   : Path.exists,
  rmv      : Path.rm,
  read     : fs.readFileSync,

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
  },
}

async function file_download_fromURL (url :URL, trg :fs.PathLike) :Promise<void> {
  const R = await fetch(url)
  if (!R.ok) fail("File.download: Tried to download a file, but failed to request its data.", JSON.stringify({url, trg, R}, null,  2))
  await File.dl.fromResponse(R, trg)
}

