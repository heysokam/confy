//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import extract from 'extract-zip'
import download from 'download'
import path, { basename, dirname } from 'path'

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

  //________________________________________________________
  // FIX: Remove this dependency. Abandonware.
  //      Fetch or ky are better. https://github.com/sindresorhus/ky
  //      It also requires got, which secretly depends on electron but doesn't list it as a dependency.
  //      Figure out downloads and just remove it.
  download : download,
  //________________________________________________________
}

