//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import { cfg as confy } from '../cfg'

export class BuildError extends Error {}

export namespace Build {
export type Options    = fs.PathLike // FIX: Accept options other than a Path
export type SourceList = fs.PathLike[]
export type FlagList   = string[]

export enum Kind { None, Program, SharedLib, StaticLib, UnitTest }
export class Target {
  kind   :Build.Kind
  src    :Build.SourceList
  cfg    :confy.Config

  constructor(opts :Build.Options) {
    this.kind  = Build.Kind.None
    this.src   = [opts]
    this.cfg   = confy.defaults.clone()
  }

  build () :this {
    return this
  } //:: confy.Build.Target.build

  run () :this {
    return this
  } //:: confy.Build.Target.run
} //:: confy.Build.Target

} //:: confy.Build

