#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________

# TODO: BuildInfo report
let info = &"""
Building {tst.name} in {tst.dir}:

  Version:          {tst.version}
  Target Binary:    {tst.trg}
  Target Platform:  {tst.syst.os}
  Target Arch:      {tst.syst.cpu}
  Host Platform:    {host.os}
  Host Arch:        {host.cpu}
  cflags:           {tst.cflags}
"""

