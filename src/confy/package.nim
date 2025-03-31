#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/strformat import `&`
# @deps confy
import ./types/base
import ./tools/version


type Info * = object
  ## @descr Describes metadata/information about a Package.
  name        *:string
  version     *:Version
  author      *:string
  license     *:string
  description *:string
  url         *:URL

func report *(info :package.Info; quiet :bool= false) :void=
  if quiet: return
  debugEcho &"""
  ...............................
  ::  Name         :  {info.name}
  ::  Version      :  {info.version}
  ::  Description  :  {info.description}
  ::  Author       :  {info.author}
  ::  License      :  {info.license}
  ::  Repository   :  {info.url}
  ::...............:
  """

