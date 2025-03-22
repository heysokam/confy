//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import * as fs from 'fs'
export default cfg; export namespace cfg {


export type Zig = {
  index  :fs.PathLike
}
export type Nim = {}
export type Dirs = {
  bin    :fs.PathLike
  src    :fs.PathLike
  lib    :fs.PathLike
  cache  :fs.PathLike
}
export const defaults :Config= {
  prefix  : "ᛝ confy:",
  verbose : false,
  quiet   : false,
  force   : false,
  dir     : {
    src   : "src/",
    lib   : ".lib/",
    bin   : "bin/",
    cache : ".cache/",
  },
  zig     : {
    index : "zig.index.json"
  }
}


export type Config = {
  prefix   :string
  verbose  :boolean
  quiet    :boolean
  force    :boolean
  dir      :cfg.Dirs
  zig      :cfg.Zig
}

} //:: cfg

export const defaults = cfg.defaults

