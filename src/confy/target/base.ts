//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps confy
import * as log from '../log'
import { cfg as confy } from '../cfg'
import { Lang } from '../lang'
import * as T from './types'
import { Manager } from '../manager'

export class BuildError extends Error {}

export namespace Build {
export type Options    = fs.PathLike // FIX: Accept options other than a Path
export type SourceList = T.SourceList
export enum Kind { None, Program, SharedLib, StaticLib, UnitTest }  // FIX: Why is TS not letting this be stores+aliased from ./types.ts ?

export async function validate (
    L    : Lang.ID,
    cfg  : confy.Config = confy.defaults.clone(),
  ) :Promise<void> { switch (L) {
  case Lang.ID.C  : /* fall-through */
  case Lang.ID.Cpp: /* fall-through */
  case Lang.ID.Zig: return await Manager.Zig.validate(cfg)
  case Lang.ID.Nim: return await Manager.Nim.validate(cfg)
  default: throw new BuildError("Unimplemented compiler validation for Lang: "+Lang.name(L))
}}

export namespace Command {
  export function C (
    ) :string[] {
    return [""]
  } //:: confy.Build.Command.C
} //:: confy.Build.Command

export class Target {
  kind   :Build.Kind
  src    :Build.SourceList
  cfg    :confy.Config
  lang   :Lang.ID

  constructor(
      opts : Build.Options,
      cfg  : confy.Config = confy.defaults.clone(),
    ) {
    this.kind  = Build.Kind.None
    this.src   = [opts]
    this.cfg   = cfg
    this.lang  = Lang.identify(this.src)
  }

  async build () :this {
    await Build.validate(this.lang, this.cfg)
    log.dbg(this.cfg, "Building")
    return this
  } //:: confy.Build.Target.build

  run () :this {
    log.dbg(this.cfg, "Running")
    return this
  } //:: confy.Build.Target.run
} //:: confy.Build.Target

} //:: confy.Build

