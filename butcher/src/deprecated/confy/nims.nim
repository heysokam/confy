
#_________________________________________________
# General tools
#___________________
template info  *(msg :string)= echo cfg.prefix & msg  ## @descr Logs a message to console
template info2 *(msg :string)= echo cfg.tab    & msg  ## @descr Logs a tabbed message to console
template fail  *(msg :string)= quit cfg.prefix & msg  ## @descr Logs a message to console and quits
proc dbg *(msg :string) :void=
   when debug: info msg
proc dbg2 *(msg :string) :void=
   when debug: info2 msg
#___________________
proc sh *(cmd :string; dir :string= ".") :void=
  ## @descr Runs the given command with a shell.
  ## @arg cmd The command to run
  ## @arg dir The folder from which the {@link:arg cmd} command will be run.
  if not cfg.quiet: info &"Running {cmd} from {dir} ..."
  try:
    withDir dir: exec cmd
  except: fail &"Failed running {cmd}"
  if not cfg.quiet: info &"Done running {cmd}."
#___________________
proc getModTime *(file :string) :string=
  when hostOS == "windows": return
  let lines = gorge( &"stat {file.absolutePath}" ).splitLines
  for line in lines:
    if line.startsWith("Modify:"): return line.replace("Modify: ", "")
#___________________
proc writeModTime *(src,trg :string) :void=
  when hostOS == "windows": return
  let dir = trg.splitFile.dir
  if not dir.dirExists: mkDir dir
  trg.writeFile( src.getModTime() )

