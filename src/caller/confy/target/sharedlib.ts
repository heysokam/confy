//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import { Build } from './base'

export class SharedLib extends Build.Target {
  constructor (args :Build.Options) {
    super(args)
    this.kind = Build.Kind.SharedLib
  }
}

