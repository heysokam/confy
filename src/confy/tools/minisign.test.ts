//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps std
import * as fs from 'fs'
// @deps test
import { beforeAll, describe, expect, it } from 'bun:test'
// @deps confy
import { File, Path } from './files'
import { Zig } from '../get/zig'
import minisign from './minisign'

type Version  = { version :fs.PathLike, url :URL }
// type Versions = Version[]
const test_version = [
  [ "0.12.0", "https://zig.nekos.space/zig/0.12.0/zig-linux-x86_64-0.12.0.tar.xz"       ],
  [ "0.12.0", "https://zigmirror.hryx.net/zig/0.12.0/zig-linux-x86_64-0.12.0.tar.xz"    ],
  [ "0.13.0", "https://zig.linus.dev/zig/0.13.0/zig-linux-x86_64-0.13.0.tar.xz"         ],
  [ "0.13.0", "https://zigmirror.nesovic.dev/zig/0.13.0/zig-linux-x86_64-0.13.0.tar.xz" ],
  // Reliable
  [ "0.13.0", "https://fs.liujiacai.net/zigbuilds/0.13.0/zig-linux-x86_64-0.13.0.tar.xz"],
  [ "0.14.0", "https://pkg.machengine.org/zig/0.14.0/zig-linux-x86_64-0.14.0.tar.xz"    ],
  [ "0.14.0", "https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz"      ],
]; const testDir = "./bin/.tests/minisign"

namespace setup { export namespace version {
  function  url_sig (V :Version) :URL { return new URL(V.url+Zig.minisign.extension.toString()) }
  function name_tar (V :Version) :fs.PathLike { return Path.basename(V.url.toString()) }
  export function path_tar (V :Version) :fs.PathLike { return Path.join(testDir, name_tar(V)) }
  export function path_sig (V :Version) :fs.PathLike { return path_tar(V)+Zig.minisign.extension }

  export async function download (V :Version) :Promise<void> {
    // Signature data
    const sig = path_sig(V)
    if (File.exists(sig)) return
    else File.create(sig)
    expect(async () => { await File.download(url_sig(V), sig) }).not.toThrowError()
    // Tar data
    const tar = path_tar(V)
    if (File.exists(tar)) return
    else File.create(tar)
    expect(async () => { await File.download(V.url, tar) }).not.toThrowError()
  }
}}

namespace test {
  export function validate (V :Version) {
    const data_tar = File.read(setup.version.path_tar(V))
    const data_sig = File.read(setup.version.path_sig(V))
    const key      = minisign.parseKey(Zig.minisign.Key)
    const sig      = minisign.parseSignature(data_sig)
    const result   = minisign.verifySignature(key, sig, data_tar)
    expect(result).toBeTruthy()
  }
  export const each = it.each;
}

beforeAll(() => {
  for (const V of test_version) setup.version.download({version:V[0], url: new URL(V[1])})
})

describe("minisign.js", () => {
  test.each(test_version)("should successfully validate signature for [%s, %s]", (version, url) => { test.validate({version, url: new URL(url)}) })
}) //:: minisign.js

