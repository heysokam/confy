#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________

type ZigFile * = object
  tarball  *:string
  shasum   *:string
  size     *:string

type ZigData * = object
  version             *:string
  date                *:string
  docs                *:string
  stdDocs             *:string
  notes               *:string
  src                 *:ZigFile
  bootstrap           *:ZigFile
  `x86_64-macos`      *:ZigFile
  `aarch64-macos`     *:ZigFile
  `x86_64-linux`      *:ZigFile
  `aarch64-linux`     *:ZigFile
  `riscv64-linux`     *:ZigFile
  `powerpc64le-linux` *:ZigFile
  `powerpc-linux`     *:ZigFile
  `x86-linux`         *:ZigFile
  `x86_64-windows`    *:ZigFile
  `aarch64-windows`   *:ZigFile
  `x86-windows`       *:ZigFile

type ZigVersion * = object
  name  *:string
  data  *:ZigData

type ZigIndex * = seq[ZigVersion]

