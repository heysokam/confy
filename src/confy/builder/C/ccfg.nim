#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# Configuration specific to Clang and GCC  |
#__________________________________________|
# std dependencies
import std/os
# confy dependencies
import ../../cfg


let gcc     * = if cfg.verbose: "gcc -v"     else: "gcc"
var gpp     * = if cfg.verbose: "g++ -v"     else: "g++"
var clang   * = if cfg.verbose: "clang -v"   else: "clang"
var clangpp * = if cfg.verbose: "clang++ -v" else: "clang++"

