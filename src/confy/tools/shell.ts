//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
import * as node from 'child_process'

export async function run (...args:unknown[]) {
  const proc = Bun.spawn([...(args as string[])], {stdout: "inherit", stderr: "inherit"})
  return await proc.exited
}

export function exec (...args:string[]) {
  const cmd  = args.toString()
  const proc = node.exec(cmd, {shell: "sh"} as node.ExecOptions, undefined)
  return proc.exitCode
}
