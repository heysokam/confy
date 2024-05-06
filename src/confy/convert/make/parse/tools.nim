# @deps ndk
import nstd/paths
# @deps make.parse
import ../types

const echo = debugEcho

#_______________________________________
func report *(lists :seq[MakeList]) :void=
  ## @descr Report Makelists information to console
  for entry in lists:
    echo "\n\n\n"
    for name,field in entry.fieldPairs():
      assert field != field.type.default()
      echo name, " : ",field

#_______________________________________
proc generated *(targets :MakeInputs; at :Path) :bool=
  ## @descr Returns true if all of the {@arg targets} have been generated inside {@arg at}.
  ## @note Returns false if at least one of them is not
  if not at.dirExists(): return false
  for trg in targets:
    let dir = at/trg.dir
    if not dirExists(dir): return false
    let file = (dir/trg.name).addFileExt(".sh")
    if not fileExists(file): return false
  return true

