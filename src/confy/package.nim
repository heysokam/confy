#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
import std/os
from std/strformat import `&`, fmt
# @deps confy
import ./types/base
import ./types/build
import ./tools/version
from ./systm as sys import nil


#_______________________________________
# @section Package Information Report
#_____________________________
const Templ_PackageInfo = """
  ...............................
  ::  Name         :  {info.name}
  ::  Version      :  {info.version}
  ::  Description  :  {info.description}
  ::  Author       :  {info.author}
  ::  License      :  {info.license}
  ::  Repository   :  {info.url}
  ::...............:
  """
#___________________
type Info * = object
  ## @descr Describes metadata/information about a Package.
  name        *:string
  version     *:Version
  author      *:string
  license     *:string
  description *:string
  url         *:URL
#___________________

func report *(
    info  : package.Info;
    quiet : bool= false;
    templ : static string= Templ_PackageInfo;
  ) :void=
  ## @descr Reports information about the given package {@link Info} data on CLI.
  if quiet: return
  debugEcho fmt( templ )

