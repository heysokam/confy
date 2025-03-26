//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import * as util from 'util'
import * as os from 'child_process'
export namespace shell {


export async function run (...args:unknown[]) {
  // FIX: Change to node.spawn
  const proc = Bun.spawn([...(args as string[])], {stdout: "inherit", stderr: "inherit"})
  return await proc.exited
} //:: shell.run


export async function exec_node (opts :os.ExecOptions, ...args:string[]) {
  const cmd  = args.join(" ")
  const proc = util.promisify(os.exec)
  const out  = await proc(cmd, opts)
  return out
} //:: shell.exec

export async function exec (opts :any, ...args:string[]) {
  // FIX: Change to node.spawn
  const proc = Bun.spawn(["sh", ...(args as string[])], {stdout: "inherit", stderr: "inherit", ...opts})
  return await proc.exited
} //:: shell.exec

export function sh (...args:string[]) {
  return exec({} as os.ExecOptions, ...args)
} //:: shell.sh

} //:: tools/shell


// Alternative exports
export const run  = shell.run
export const exec = shell.exec
export const sh   = shell.sh

