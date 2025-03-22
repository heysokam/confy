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
  cwd: () :fs.PathLike => { return process.cwd() },
  move: (src :fs.PathLike, trg :fs.PathLike) => {
    fs.cpSync(src as string, trg as string)
  }
}

export const File = {
  exists   : Path.exists,
  read     : fs.readFileSync,
  rmv      : Path.rm,
  write    : fs.writeFileSync,
  unzip    : extract,

  /** @description Moves {@param src} to {@param trg} by copying src to trg and removing trg on completion. */
  move: (src :fs.PathLike, trg :fs.PathLike, mode ?:number) => {
    fs.copyFileSync(src as string, trg as string, mode)
    Path.rm(src)
  },

  //________________________________________________________
  // FIX: Remove this dependency. Abandonware.
  //      Fetch or ky are better. https://github.com/sindresorhus/ky
  //      It also requires got, which secretly depends on electron but doesn't list it as a dependency.
  //      Figure out downloads and just remove it.
  download : download,
  //________________________________________________________
}

