//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
/**
 * @fileoverview
 * Tools for parsing/modifying Semantic Versions
 * Respects the parsing Specification at https://semver.org
 * */
import { ok } from 'assert'
type u64 = number

export class Version {
  major : version.Major
  minor : version.Minor
  patch : version.Patch
  tag   : version.Tag
  build : version.Build

  constructor (
      M  :version.Major|string|Version|null,
      m ?:version.Minor,
      p ?:version.Patch,
      t ?:version.Tag,
      b ?:version.Build,
    ) {
    this.major = 0
    this.minor = 0
    this.patch = 0
    this.tag   = null
    this.build = null
    if (M === null) return
    switch (typeof M) {
      case "string": return version.parse(M)
      case "number": return version.from(M, m ?? 0, p ?? 0 ,t, b)
      case "object": return version.from(M.major, M.minor, M.patch, M.tag, M.build)
    }
  }

  toString () :string {
    const tag   = this.tag   ? `-${this.tag}`   : ""
    const build = this.build ? `+${this.build}` : ""
    return `${this.major.toString()}.${this.minor.toString()}.${this.patch.toString()}${tag}${build}`
  }
}

export namespace version {
  export type Major = u64
  export type Minor = u64
  export type Patch = u64
  export type Tag   = string | null
  export type Build = string | null

  export namespace Specification {
    /**
     * @description
     * Regex found at : https://semver.org
     * Explanation    : https://regex101.com/r/vkijKf/1
     * */
    export const Regex = new RegExp('^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$', 'gm')
    export const Valid = [
      ["0.0.4",                  0,0,4, null,  null ],
      ["1.2.3",                  1,2,3, null,  null ],
      ["10.20.30",            10,20,30, null,  null ],
      ["1.1.2-prerelease+meta",  1,1,2, "prerelease", "meta"],
      ["1.1.2+meta",             1,1,2, null, "meta"],
      ["1.1.2+meta-valid",       1,1,2, null, "meta-valid"],
      ["1.0.0-alpha",            1,0,0, "alpha", null ],
      ["1.0.0-beta",             1,0,0, "beta", null ],
      ["1.0.0-alpha.beta",       1,0,0, "alpha.beta", null  ],
      ["1.0.0-alpha.beta.1",     1,0,0, "alpha.beta.1", null],
      ["1.0.0-alpha.1",          1,0,0, "alpha.1", null],
      ["1.0.0-alpha0.valid",     1,0,0, "alpha0.valid", null],
      ["1.0.0-alpha.0valid",     1,0,0, "alpha.0valid", null],
      ["1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay", 1,0,0, "alpha-a.b-c-somethinglong", "build.1-aef.1-its-okay"],
      ["1.0.0-rc.1+build.1",     1,0,0, "rc.1", "build.1"],
      ["2.0.0-rc.1+build.123",   2,0,0, "rc.1", "build.123"],
      ["1.2.3-beta",             1,2,3, "beta", null],
      ["10.2.3-DEV-SNAPSHOT",   10,2,3, "DEV-SNAPSHOT", null],
      ["1.2.3-SNAPSHOT-123",     1,2,3, "SNAPSHOT-123", null],
      ["1.0.0",                  1,0,0, null, null],
      ["2.0.0",                  2,0,0, null, null],
      ["1.1.7",                  1,1,7, null, null],
      ["2.0.0+build.1848",       2,0,0, null, "build.1848"],
      ["2.0.1-alpha.1227",       2,0,1, "alpha.1227", null],
      ["1.0.0-alpha+beta",       1,0,0, "alpha", "beta"],
      ["1.2.3----RC-SNAPSHOT.12.9.1--.12+788", 1,2,3, "---RC-SNAPSHOT.12.9.1--.12", "788"],
      ["1.2.3----R-S.12.9.1--.12+meta", 1,2,3, "---R-S.12.9.1--.12", "meta"],
      ["1.2.3----RC-SNAPSHOT.12.9.1--.12", 1,2,3, "---RC-SNAPSHOT.12.9.1--.12", null],
      ["1.0.0+0.build.1-rc.10000aaa-kk-0.1", 1,0,0, null, "0.build.1-rc.10000aaa-kk-0.1"],
      ["999999999999999.999999999999999.999999999999999", 999999999999999,999999999999999,999999999999999, null, null], // @note The spec example had too many digits for JS/TS
      ["1.0.0-0A.is.legal", 1,0,0, "0A.is.legal", null],
      ] //:: Valid

    export const Invalid :string[]= [
      "1",
      "1.2",
      "1.2.3-0123",
      "1.2.3-0123.0123",
      "1.1.2+.123",
      "+invalid",
      "-invalid",
      "-invalid+invalid",
      "-invalid.01",
      "alpha",
      "alpha.beta",
      "alpha.beta.1",
      "alpha.1",
      "alpha+beta",
      "alpha_beta",
      "alpha.",
      "alpha..",
      "beta",
      "1.0.0-alpha_beta",
      "-alpha.",
      "1.0.0-alpha..",
      "1.0.0-alpha..1",
      "1.0.0-alpha...1",
      "1.0.0-alpha....1",
      "1.0.0-alpha.....1",
      "1.0.0-alpha......1",
      "1.0.0-alpha.......1",
      "01.1.1",
      "1.01.1",
      "1.1.01",
      "1.2",
      "1.2.3.DEV",
      "1.2-SNAPSHOT",
      "1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788",
      "1.2-RC-SNAPSHOT",
      "-1.0.3-gamma+b7718",
      "+justmeta",
      "9.8.7+meta+meta",
      "9.8.7-whatever+meta+meta",
      "99999999999999999999999.999999999999999999.99999999999999999----RC-SNAPSHOT.12.09.1--------------------------------..12",
      ] //:: Invalid
  } //:: version.Spec

  class ParseError extends Error {}

  export function parse (vers:string) :Version {
    const iter = vers.matchAll(version.Specification.Regex)
    const data = iter.next().value ?? []
    if (data.length === 0) throw new ParseError("Invalid version format: "+vers+"\nSpecification references: "+"\n  https://semver.org\n  https://regex101.com/r/vkijKf/1")
    const result = new Version(null)
    ok(data[1]); ok(data[2]); ok(data[3]);
    result.major = parseInt(data[1])
    result.minor = parseInt(data[2])
    result.patch = parseInt(data[3])
    result.tag   = data[4] ?? null
    result.build = data[5] ?? null
    return result
  } //:: version.parse

  export function from (
      M  :version.Major,
      m  :version.Minor,
      p  :version.Patch,
      t ?:version.Tag,
      b ?:version.Build,
    ) :Version {
    const result = new Version(null)
    result.major = M
    result.minor = m
    result.patch = p
    result.tag   = t ?? null
    result.build = b ?? null
    return result
  } //:: version.from
} //:: version

