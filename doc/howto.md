## Overview
Confy is a Buildsystem for compiling C, C++ and Nim code.  
It is no more than an interface for calling the compilers themselves with a simpler and more ergonomic syntax.  
All it does is call `CC -o myfile.exe file.c file2.c` with the correct options for your project,  
based on the options you define in your `src/build.nim` file.  

_Important Note:_  
Unlike other buildsystems, Confy is -not- a binary that you call.  
It is a **library** that you use from inside your Builder App.  
This is much more than a semantic difference.   
More details about this in the `Builder App` section, and the disclaimer section @[the confy readme](../readme.md) file.  

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
  trg = "hello.exe",       # Define our binary
)

bin.build()                # Order to build
```
With this setup, your binary will:
```md
- Find its source code files by taking all `.c` files inside the `ROOT/src` folder
- Output the resulting binary into:
  - Folder      : `confy.cfg.binDir`, which is `ROOT/bin`.
  - Binary name : `hello.exe`
```
This means that your application will be output to: `ROOT/bin/hello.exe`


## Two Files:  The Builder and the Caller
Confy is **VERY** different to make-like buildsystems. In a big way.  
With confy, the buildsystem binary is **yours**.  

You control its flow.  
You decide when you want to `MyTarget.build()`,  
or when you want to do some low level systems programming/coding before any of that, if you so desire.  
You can do whatever you want. The builder application is yours.   

This is why you need two files to setup your project:  
```md
1. Builder : `REPO/src/build.nim`, where you define how to build your project.
2. Caller  : `REPO/projectname.nimble` or `REPO/projectname.nims` where you define how to build the builder itself.
```

### The Caller Script  (aka project.nimble or project.nims)
This is a simple `nimscript` only file that all it does is ask nim to compile your builder.  

The most minimal Caller Script file possible would be:
```nim
include confy/nims
confy()

# Run with `nim thisfile.nims`
```
That's it, really. The rest is just convenience.

This is an example of doing the same, but using nimble instead:
```nim
include confy/nims

version = "0.1.0"
author  = "Someone"
# ...
# other nimble related config here
# ...

task confy, "This task will build the project with confy":
  confy()

# Run with `nimble confy`
```
Just like with the `example.nims` file, this is just convenience.
The file can be called anything you want. It has no requirements. Just call the `confy()` function from nimscript and you are good to go.

**Building the Builder App**:
You can build your `build.nim` Builder however else you want.
All the `confy()` function does is provide some sane preconfigured defaults for you to make it easier to run the Builder.  

Like everything else in confy, you don't `need` the provided defaults.  
They are just there to make things more ergonomic and easy to use.  


### The Builder App  (aka src/build.nim)
Following the overview trend of minimalism, lets make the example `src/build.nim` file even simpler:
```nim
import confy
Program.new( @["src/mycode.c"], "hello.exe" ).build()
```
That's all, really. The rest is just for changing the defaults.

You can build and run this file in whatever way you want, and it will bould your code as expected.  
The usual way to do this will be with the Caller Script described in the prev secion.  
_Alternative: Build+Run with `nim c -r src/build.nim`_

#### Differences between C, C++ and Nim
C/C++ are built exactly the same, and Nim compiles into C.
This means that the only difference in configuration is the file you send into the `src` variable.  
```nim
# If you want to build a Nim app:
let code = @[ srcDir/"myfile.nim" ]

# If you want to build a C app with only one file:
let code = @[ srcDir/"myfile.c" ]

# If you want to build a C++ app with only one file:
let code = @[ srcDir/"myfile.cpp" ]

# If you want to build a mixed C & C++ app with two files:
let code = @[ srcDir/"file1.cpp", srcDir/"file2.c" ]
```

##### Nim
In C and C++ you will need to send all of the files, because the compiler doesn't understand dependency resolution.  
But Nim has module dependency resolution.  
As such, the only uniqueness for building Nim is that you can only send one `.nim` file for each object you build.  

##### C and C++
The `SomeFolder.glob()` function is created so that you don't need to explicitly list all files in your project manually,  
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
_I would never recommend this, but... your project, your rules._

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
See the @[config.md](./config.md) doc file, or @[confy/cfg.nim](../src/confy/cfg.nim) for the complete list of variables that can be modified.
