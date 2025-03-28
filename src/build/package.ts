//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
/**
 * @fileoverview
 * Automatically updates confy's package.json using its internal configuration.
 * Should be run during confy's build process.
 * */
// @deps confy
import pkg from '../../package.json'
import { File } from '../confy/tools/files'
import { cfg } from '../confy/cfg'

const icon         = (!cfg.tool.icon ) ? cfg.tool.icon  : `${cfg.tool.icon} `
const description  = (!cfg.tool.descr) ? cfg.tool.descr : ` ${cfg.tool.separator.descr} ${cfg.tool.descr}`
const result       = structuredClone(pkg)
result.name        = cfg.tool.pkgName
result.version     = cfg.tool.version.toString()
result.description = `${icon}${cfg.tool.name}${description}`
File.write("./package.json", JSON.stringify(result, null, 2))

