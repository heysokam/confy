#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
{.error:"Tasks and keywords need to be reimplemented for the refactor of 2.0.0".}
# std dependencies
import std/sets
import std/hashes
# confy dependencies
import ./base
import ./state

#_______________________________________
# Task List
#___________________
proc task *(name,descr :string; call :TaskCallback; always=off; categories :seq[string]= @[]) :void {.inline.}=
  ## Creates a generic task to execute.
  ## Runs the task where it is declared if its name is found in the user-requested keywords.
  ##
  ## The task will run if:
  ## - `always` is active.   (The task will always run, no matter if it was requrested or not)
  ## - Its `name` is found in the user-requested keywords.
  ## - The keyword "tasks" is requested.   (Requesting `tasks` in cli will make all defined tasks run)
  ## - One of the categories is found in the user-requested keywords.
  taskList.incl Task(name:name, descr:descr, call:call)
  if always or "tasks" in keywordList : call()
  elif name in keywordList            : call()
  elif categories.len != 0:
    for it in categories:
      if it in keywordList: call()
#___________________
proc runAllTasks *() :void {.inline.}=
  ## Runs all tasks known by confy (ie: all tasks in the taskList), no matter if they were requested in CLI or not.
  for it in taskList: it.call()

