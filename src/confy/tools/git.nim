#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
##! @fileoverview Confy's Git Management tools
#______________________________________________|
from std/os import `/`, fileExists
from std/strformat import fmt

#_______________________________________
# @section Comptime Defaults
#_____________________________
const git_server *{.strdefine.}= "https://github.com"
const git_owner  *{.strdefine.}= "UndefinedOwner"
const git_repo   *{.strdefine.}= "UndefinedRepository"


#_______________________________________
# @section Git Info: Types
#_____________________________
type Repository * = object
  ## @descr Describes metadata/information about a Git repository and the tools to manage it.
  server  *:string=  git_server
  owner   *:string=  git_owner
  name    *:string=  git_repo


#_______________________________________
# @section Git Info: Helpers
#_____________________________
const Templ_GitURL * = "{repo.server}/{repo.owner}/{repo.name}"
func `$` *(repo :git.Repository; templ :static string= Templ_GitURL) :string= fmt( templ )
  ## @descr Converts the given git {@arg info} object into its corresponding URL
func url *(repo :git.Repository) :string= $repo
  ## @descr Converts the given git {@arg info} object into its corresponding URL


#_______________________________________
# @section Git: Ignore
#_____________________________
const Data_ignoreAll * ="""
*
"""  ## Completely hides a folder from git
#___________________
const Data_ignore * = """
*
!.gitignore
"""  ## Hides all files in a folder, but not the folder
#___________________
proc hide *(dir :string) :void=
  let file = dir/".gitignore"
  if file.fileExists: return
  file.writeFile(git.Data_ignoreAll)
#___________________
proc ignore *(dir :string) :void=
  let file = dir/".gitignore"
  if file.fileExists: return
  file.writeFile(git.Data_ignore)

