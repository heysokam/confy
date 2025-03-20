//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import * as fs from 'fs'


export const cfg_default :Config= {
  prefix  : "ᛝ confy:",
  verbose : false,
  quiet   : false,
  force   : false,
  dir     : {
    src   : "src",
    lib   : "lib",
    bin   : "bin",
  }
}

export type ConfigDirs = {
  bin  :fs.PathLike
  src  :fs.PathLike
  lib  :fs.PathLike
}

export type Config = {
  prefix   :string
  verbose  :boolean
  quiet    :boolean
  force    :boolean
  dir      :ConfigDirs
}
