## Design Decisions
Please read the @[how to](./howto.md) doc before reading this section:

### Imperative, not Declarative
When most people think of a build tool, they think of declarativeness.  
This is **not** what Confy is.  

With declarativeness, they'd think of writing:
```js
export let CC  = “gcc”
export let app = program()
app.add(“./src/hello.c”)
```
Then they'd call the build tool, which would import/require their file.  
The internal buildsystem manager would then deal with sorting the code, and solving any inter-dependencies declared by the user.  
The user, thus, would **not** own the flow of their build tool.  
They can only -declare- what they want, not tell the computer what they want and when.  

Declarativeness means that if you want to:
1. Download repository A
2. Patch it
3. Enter A's folder
4. Call -their- buildsystem (eg: make)
5. and only THEN build your app ...  

You can't... because you have to declare the code, not run it.  

In this simple case:
- You cannot enter the folder and call a custom tool on its contents.  
  The repository does not exist. It has not been downloaded yet.  
- You need to declare what tool will be run, and how it works.  
- ... declare what folder the builder will enter, and when it will be available.  
- ... declare what action to run and with which tool  
- ... declare that the action depends on the folder already existing.  
- ... declare how to patch the repository, and which files will need and when.  
- ... declare how the repository's buildsystem is run
- ... declare which files must exist after running, and how to wait for them to be done.
- ... ...

_There is a clear pattern forming already, and this is the simplest case._  

This means that, with declarativeness, the buildsystem needs to:  
- Polute the user's buildsystem with tens (or hundreds) of extra lines of boilerplate code,  
  so that they can declare their inter-dependencies using your api.  
- Implement a graph solver  
- Implement a dependency resolution manager  
- Decide which preset of tools to provide to the user.  
  _Any tools you don't provide with your VM, the user must figure out themselves._  
- Implicitly restrict what the user can do with their buildsystem. Your premade api is all they have.  
- _and a bunch more other issues..._  

This is what make/cmake/ninja/scons/etc do, and that's why they get so messy  

Now, instead, turn the buildsystem **imperative** and **compiled**.  
Those issues are **all** gone.  

As such, Confy instead is completely imperative.  
What you tell Confy to do, it will do **immediately**.  

The core the concept behind Confy is that you fully own your buildsystem.  
Its your project, and only you can know what your project/tooling needs,  
and in which exact order.  


### `build.nim` is NOT a buildscript
Confy is a buildsystem **library**.  
The default setup provides you with an easy way to run it as if it was a binary,  
but confy is, by design, **not** a binary app.  

**Your build file** (not confy) will be a full systems binary application,  
that you compile with nim's compiler _(or automated with confy's premade caller)_ to build your project.  

Because of this:
- There is no weird make-specific or shell-only language restrictions, like make/cmake.  
- There is no interpreted-language restrictions either, like in python.  
- There is no "can only do what the VM can do" problems either, like nimscript or lua.  
- Your builder will be a full systems binary, that will be able to do literally anything you want.  

In declarative buildsystems _(eg: make, cmake, ninja, etc)_, you **do not own** the control flow.  
If you want to do extra things that the buildsystem creators didn't think of, you are on your own.  
And you must call for external applications, which will make your buildsystem immediately platform-dependent and overly complicated for no reason.  

Confy, instead, provides you with a -library- of tools to build your project.  
It designed to make this process seamless and ergonomic, as if it was a regular buildscript.  
But your builder app will be a compiled systems binary.  
It will be able to do literally -anything- a normal compiled systems binary can do.  


### Why ZigCC
> Support for compilers other than ZigCC will **never** be implemented.   
> This is why.

Picture this.  
You are implementing a buildsystem tool.  
You start writing support for compiling your projects.  
You start coming up with a strategy as you continue implementing, in an attempt to plan for the future.  

At some point you realize will _eventually_ have to write support for:
- msvc/mingw/msys on windows
- gcc/clang on linux
- clang on macos
- unknown compiler on some other arbitrary OS
- Depend on the user to have libc libraries installed correctly
- Setup cross-compilation manually, and separately, **for every platform**.  
  _And that's asuming the platform has good cross-compilation support (most don't)_
- Arbitrary compiler flags support
- .... etc, etc, etc ...  

Annoyed by the fragmented ecosystem, you give up and rely on the user to do all the heavy work.  
Now your project became just another version of make/cmake/etc.  
Which means you became just as hard to use, setup and manage for newcomers.  

Alternatively, you consider using ZigCC.  
ZigCC comes with all of these features **builtin**, out of the box. No extra setup:
- Automatic Caching
- Cross-platform Cross-compilation
  _(from any system to any system, not just some to some)_
- Auto-dependency resolution
- Preconfigured Sanitization
- Sane and Modern optimization defaults
- Pre-packed libc

... and all of that fits in a self-contained 50mb download!  

I say there is a clear winner here.  

