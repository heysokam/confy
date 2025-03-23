//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import extract from 'extract-zip'
import path, { basename, dirname } from 'path'
import { Readable } from 'stream'

export const Path = {
  basename: basename,
  dirname: dirname,

  exists : (path :fs.PathLike) :boolean => { return fs.existsSync(path) },
  rm     : (path :fs.PathLike) => { fs.rm(path, () => {}) },
  join   : (...paths:fs.PathLike[]) :fs.PathLike=> path.join(...paths.flatMap(a => a.toString()))
}

export const Dir = {
  cwd    : () :fs.PathLike => { return process.cwd() },
  move   : (src :fs.PathLike, trg :fs.PathLike) => fs.cpSync(src as string, trg as string),
  create : (trg :fs.PathLike, recursive :boolean= true) => fs.mkdirSync(trg, {recursive: recursive}),
}

export const File = {
  exists   : Path.exists,
  read     : fs.readFileSync,
  rmv      : Path.rm,
  unzip    : extract,

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
   * @note Untested on folders. Likely won't work ?
   * */
  download : file_download_fromURL,
  dl: {
    /**
     * @description
     * Downloads the file hosted at the url of the {@param R} Response into the {@param trg} file.
     * @note Untested on folders. Likely won't work ?
     * */
    fromResponse : async(R :Response, trg :fs.PathLike) :Promise<void>=> await fs.promises.writeFile(trg, Readable.fromWeb(R.body ?? {} as any)),
    fromURL      : file_download_fromURL,
  },
}

async function file_download_fromURL (url :URL, trg :fs.PathLike) :Promise<void> {
  await File.dl.fromResponse(await fetch(url), trg)
}

