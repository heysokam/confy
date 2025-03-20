//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import { Config, cfg_default } from '@confy/cfg'

export class BuildTarget {
  src  :fs.PathLike[]
  cfg  :Config

  constructor(path :fs.PathLike) {
    this.src = [path]
    this.cfg = cfg_default
  }
}

