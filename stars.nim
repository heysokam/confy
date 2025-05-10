proc build(name: string) =
  var systemBuild = libraryBuild
  systemBuild.cfg.nim.systemBin = true
  systemBuild.cfg.nim.bin = "nim"
  systemBuild.cfg.dirs.src = sourceLibrary
  systemBuild.flags = Flags(
    cc: @[ "-static", "-march=core2", "-msse2", "-mno-avx", "-mno-avx2", "-mno-avx512f" ],
    ld: @[ "-static" ],
  )
  systemBuild.args = @[
    "--out:" & name & ".dll",
    "-d:noSignalHandler",
  ]
  systemBuild.build()

