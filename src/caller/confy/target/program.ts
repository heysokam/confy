//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import { Build } from './base'
import { cfg as confy } from '../cfg'

export class Program extends Build.Target {
  constructor (
      opts : Build.Options,
      cfg  : confy.Config = confy.defaults.clone(),
    ) {
    super(opts, cfg)
    this.kind = Build.Kind.Program
  }
}

