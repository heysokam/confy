//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps confy
import { SourceList, SourceFile } from "../target/types";
import { Path, File } from '../tools';
class LangError extends Error {}
export namespace Lang {
export enum ID { Unknown, Asm, C, Cpp, Zig, Nim, Minim }
export const name = (id :Lang.ID) :string=> (Object.values(Lang.ID)[id] ?? "").toString()

namespace Identify {
  /**
   * @description
   * Returns the language of the {@param ext} file extension.
   * */
  export function ext (
      ext : string
    ) :Lang.ID { switch (ext) {
    case ".s"   : return Lang.ID.Asm
    case ".c"   : return Lang.ID.C
    case ".cc"  : /* fall-through */
    case ".cpp" : return Lang.ID.Cpp
    case ".zig" : return Lang.ID.Zig
    case ".nim" : return Lang.ID.Nim
    case ".cm"  : /* fall-through */
    case ".zm"  : return Lang.ID.Minim
    default     : return Lang.ID.Unknown
  }} //:: confy.Lang.Identify.ext

  /**
   * @description
   * Returns the language of the {@param src} file, based on its extension.
   * */
  export function file (
      src : SourceFile
    ) :Lang.ID {
    const result = Identify.ext(Path.ext(src)) || Identify.ext(File.findExtension(src))
    if (result === Lang.ID.Unknown) throw new LangError("Couldn't find the language of a file using its extension: "+src.toString())
    return result
  } //:: confy.Lang.Identify.file

  /**
   * @description
   * Returns the language of the {@param src} list of files, based on their extension.
   * */
  export function list (
      src : SourceList
    ) :Lang.ID {
    const langs = new Set<Lang.ID>()
    for (const file of src) langs.add(Identify.file(file))
         if (langs.has(Lang.ID.Nim  )) return Lang.ID.Nim
    else if (langs.has(Lang.ID.Minim)) return Lang.ID.Minim
    else if (langs.has(Lang.ID.Zig  )) return Lang.ID.Zig
    else if (langs.has(Lang.ID.Cpp  )) return Lang.ID.Cpp
    else if (langs.has(Lang.ID.C    )) return Lang.ID.C
    else if (langs.has(Lang.ID.Asm  )) return Lang.ID.Asm
    return Lang.ID.Unknown
  } //:: confy.Lang.Identify.list
} //:: confy.Lang.Identify

/**
 * @description
 * Returns the language of the {@param src} file or list of files, based on their extension.
 * */
export function identify (
    src : SourceList | SourceFile
  ) :Lang.ID {
  if (Array.isArray(src)) return Identify.list(src)
  else                    return Identify.file(src)
} //:: confy.Lang.identify

} //:: confy.Lang

