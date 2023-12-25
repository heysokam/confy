## Overview
Confy is a Buildsystem for compiling C, C++ and Nim code.  
It is no more than an interface for calling the compilers themselves with a simpler and more ergonomic syntax.  
All it does is call `CC -o myfile.exe file.c file2.c` with the correct options for your project,  
based on the options you define in your `src/build.nim` file.  

> _Important Note:_  
> Unlike other buildsystems, Confy is -not- a binary that you call.  
> Confy is a **library** that you use from inside your Builder App.  
> This is much more than a semantic difference.   
> More details about this in the `Builder App` section, and the disclaimer section @[the confy readme](../readme.md) file.  

## Basics
Confy has sane defaults preconfigured.  
You don't need to change anything if you want to use the preconfigured project structure.  
That said, if you want a different setup, you can have it by changing the options described in the @[config.md](./config.md) doc file.  

A simple build file you could look like:
```nim
import confy

let code = srcDir.glob()   # Get our source by grabbing all code from the `srcDir` folder
var bin  = Program.new(    # Build an executable program
  src = code,              # Define our source code
  trg = "hello",           # Define our binary
)

bin.build()                # Order to build
```
With this setup, your binary will:
```md
- Find its source code files by taking all `.c` files inside the `ROOT/src` folder
- Output the resulting binary into:
  - Folder      : `confy.cfg.binDir`, which is `ROOT/bin`.
  - Binary name : `hello.exe` on windows, `hello` on linux, `hello.app` on mac
```
> This means that your application will be output to: `ROOT/bin/hello.exe`  


## Two Files:  The Builder and the Caller
Confy is **VERY** different to make-like buildsystems. In a big way.  
With confy, the buildsystem binary is **yours**.  

You control its flow.  
You decide when you want to `MyTarget.build()`,  
or when you want to do some low level systems programming/coding before any of that, if you so desire.  
You can do whatever you want. The builder application is yours.   

This is why you need two files to setup your project:  
1. **Builder**: Where you define how to build your project.  
  `REPO/src/build.nim`  

2. **Caller**: Where you define how to build the builder itself.  
  `REPO/projectname.nimble` or `REPO/projectname.nims`  

> **Important**:  
> Like everything else in confy, you don't `need` these defaults.  
> The only required part is that you build a binary that uses the confy functions and config options.  
> This setup is here just to make things easy and ergonomic to use.  


### The Caller Script
_(aka `./project.nimble` or `./project.nims`)_  

The Caller Script is a simple `nimscript` file that asks nim to compile your builder.  

The most minimal Caller Script file possible would be:
```nim
include confy/nims
confy()
```
That's it, really. The rest is just convenience.

To build the project, you have two options:
- Run `nim thefile.nims`
- Create a nimble task so you can build by running `nimble confy`:
  ```nim
  version = "0.1.0"
  author  = "Someone"
  # ...
  # other nimble related config here
  # ...

  task confy, "This task will build the project with confy":
    requires "https://github.com/heysokam/confy#head"
    exec "nim confy.nims"
  ```
> Note:  
> Just like with the `example.nims` file, this is just convenience.  
> The file can be called anything you want. It has no requirements.  
> Just call the `confy()` function from nimscript and you are good to go.  

> Important:  
> You can build your `build.nim` Builder App however else you want.  
> All the `confy()` function does is provide some sane preconfigured defaults for you to make it easier to run the Builder.  


### The Builder App
_(aka `./src/build.nims`)_  

The Builder App is the actual application that will build your project.  
This is the only required part of confy.  
Compile the Builder App, run it, and that's it.  

Following the trend of minimalism, lets make the previous example `src/build.nim` file even simpler:
```nim
import confy
Program.new( @["src/mycode.c"], "hello" ).build()
```
> That's all, really. The other options are just for changing the defaults.

You can build this file in whatever way you want, and running it will build your code as expected.  
The easiest way to do this is with the [Caller Script setup](#the-caller-script) described in the prev secion.  
> _Alternative: Build+Run with `nim c -r src/build.nim`_

#### Differences between C, C++ and Nim
C/C++ are built exactly the same, and Nim compiles into C.
The only difference between them is the files you send into the `src` variable.  
```nim
# If you want to build a Nim app:
let code = @[ srcDir/"myfile.nim" ]

# If you want to build a C app with only one file:
let code = @[ srcDir/"myfile.c" ]

# If you want to build a C++ app with only one file:
let code = @[ srcDir/"myfile.cpp" ]
```

##### Nim
Nim has module dependency resolution.  
The only uniqueness for building Nim is that you can only send one `.nim` file for each object you build.  

##### C and C++
In C and C++ you will need to send all of your source files, because the compiler doesn't understand dependency resolution.  
The `SomeFolder.glob(".ext")` function is created so that you don't need to explicitly list all files in your project manually,  
and -also- maintain the list manually _(which is a giant PITA, time consuming, and extremely error and bug prone)_.  

That said, you can also explicitely list the files manually if you so desire.  
This works for the same for both C and C++ files (including mixed C & C++ projects):
```nim
let code = @[
  "./mycode/file1.c",
  "./myother/file2.c",
  "./otherfolder/file4.c",
  # ... list 100 other files one by one in here ...
  ]
```
> _I would never recommend this, but... your project, your rules._


## Other Examples:
More ways to configure the buildsystem are shown @[the examples](./examples) folder.  
You can use those projects as templates for a new project, or just use them as inspiration instead.  


## Buildsystem Customization
All the configuration variables are stored @[confy/cfg.nim](./src/confy/cfg.nim).  
To change them, just add `cfg.theVariable = value` at the top of your `build.nim` file.  
```nim
import confy
cfg.srcDir  = "./code"
cfg.binDir  = "./build"
cfg.verbose = off
cfg.quiet   = on
```
> See the @[config.md](./config.md) doc file, or @[confy/cfg.nim](../src/confy/cfg.nim) for the complete list of variables that can be modified.

## Keywords
> _WIP: this section needs a better explanation_  

```nim
make debug
make mytarget
make clean
```
`debug` `clean` `mytarget` etc... are all **Keywords**  
In confy, those keywords are defined when you call to build the target  
If you say:  
```nim
bin.build( keywords = @["thing", "otherkeyword"], run=true )
```
That means you *need* to call the confy builder with that keyword, otherwise it wont build that target because its filtered away.  
To trigger that keyword manually, you would have to say `build.exe thing` or `build.exe otherkeyword`.  

Currently _(v0.1.7)_ the `confy/nimble` file does not pass keywords into the builder. Only the `confy/nims` task does.  
Easiest way to work around this with nimble is to remove the keywords field and use version >= 0.1.7,  
which adds an implied `"all"` keyword that runs when you don't specify anything:  
```nim
var bin = Program.new("my/source/file.nim", "mytarget")
bin.build( run=true )  # <-- automatically implied:   keywords = @["all", "mytarget"]

# Build it with:
#>  ./bin/build.exe               <-- Implied "all"
#>  ./bin/build.exe all           <-- Explicit "all"
#>  ./bin/build.exe mytarget      <-- Explicit target name
```
