#_____________________________
# Remotes Management
#_____________________________
proc adjustRemotes *(obj :var BuildTrg) :void=
  ## @descr
  ##  Adjusts the list of source files in the object, based on its remotes.
  ##  Files will be:
  ##  - Searched for in `cfg.srcDir` first.
  ##  - Adjusted to come from the folders stored in the obj.remotes list when the local file is missing.
  for file in obj.src.mitems:
    # Dont adjust object files. They don't need to be compiled
    if file.path.string.endsWith(".o"): continue
    # Dont adjust if the file exists
    if file.path.fileExists:
      if cfg.verbose: log1 &"Local file exists. Not adjusting :  {file.path}"
      continue
    # Adjust for a missing extension with Nim
    elif obj.lang == Lang.Nim and (not file.path.string.endsWith(".nim")):
      log1 &"Nim file was sent without extension. Searching for it at  {file.path}"
      file = file.findNoExt(Lang.Nim)
      continue
    # Search for the file in the remotes
    if obj.remotes.len < 1: cerr &"The source code file {file.path} couldn't be found."
    if cfg.verbose: echo " ... "; log1 &"File {file.file} doesn't exist in local. Searching for it in the remote folders list."
    for dir in obj.remotes:  # Search for the file in the remotes
      let adj = file.fromRemote(dir, obj.sub)
      if cfg.verbose: log1 &"File:  {file.path}\n{tab}Becomes:  {adj.path}"
      file = adj

