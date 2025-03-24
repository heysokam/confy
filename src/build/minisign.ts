//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
/**
 * @fileoverview
 * Automatically downloads minisign.js from @mlugg/setup-zig into @confy/tools
 * Should be run during confy's build process.
 *
 * @note
 * Ideally minisign should be an npm package instead, but :shrug:
 * */
// @deps confy
import { Default as log } from "@confy/log"
import { File } from "@confy/tools"

const url = new URL("https://raw.githubusercontent.com/mlugg/setup-zig/refs/heads/main/minisign.js")
const trgDir  = "./src/confy/tools/"
const trgFile = trgDir+"minisign.js"

if (import.meta.main) try { run() } catch { throw new Error("[FATAL]: Failed to build MiniSign from: "+url)}
async function run() :Promise<void> {
  log.info("Build: Downloading @mlugg/setup-zig/minisign.js to "+trgFile)
  await File.download(url, trgFile)
}

