#!/bin/sh
set -eu
#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
#:______________________________________________________________________
curl -s https://raw.githubusercontent.com/heysokam/get.Lang/master/get.Zig.sh | bash

#_______________________________________
# @section Configure
#_____________________________
# General
binDir=./bin
srcDir=./src
builder=$srcDir/build.zig
tester=$srcDir/tests.zig
# Zig
cacheDir=$binDir/.cache/zig
zigDir=$binDir/.zig
zig=$zigDir/zig


zbuild() { $zig build-exe -femit-bin=$binDir/build --cache-dir $cacheDir --global-cache-dir $cacheDir $builder && $binDir/build ; }
ztest()  { $zig test -femit-bin=$binDir/tests --cache-dir $cacheDir --global-cache-dir $cacheDir $tester && $binDir/tests       ; }
#_______________________________________
# @section Build
#_____________________________
# Order to Build the Project with Confy's defaults
# $zig version
if [[ $# -eq 0 ]] then
  zbuild
else
  [[ $1 == 'only' ]] && zbuild
  [[ $1 == 'test' ]] && ztest
fi

