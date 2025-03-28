//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import cfg from '@confy/cfg'

export class BuildTarget {
  src  :fs.PathLike[]
  cfg  :cfg.Config

  constructor(path :fs.PathLike) {
    this.src = [path]
    this.cfg = cfg.defaults.clone()
  }
}

