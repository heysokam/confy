//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________

export async function run (...args:unknown[]) {
  const proc = Bun.spawn([...(args as string[])], {stdout: "inherit", stderr: "inherit"})
  return await proc.exited
}

