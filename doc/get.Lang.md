> TODO:  
> Port this description to confy/tools

# get.Lang | Automated download of Programming Languages
`get.Lang` is a set of tools to automate the download of Programming Languages.  
It can be used either as an application, or as a collection of functions in your own code.  

```md
# Currently Supported
- Zig / ZigCC (can compile C & C++)
- Nim
- Minim
- TypeScript (bun)
```

## How-to
`get.Lang` can work either as a **library** or as a binary **application**.  
Both are equally supported.

```md
# Installation
nimble install https://github.com/heysokam/get.Lang
```

```md
# As an Application
get zig                     # Install zig using the default options
get nim --trgDir:./mydir    # Install nim to `./mydir`

get -h                      # List all the available options and their defaults
```

```nim
# As a Library
import get

zig.get(
  dir     = TARGET_DIR,       # Path where the language will be installed
  index   = JSON_INDEX_NAME,  # Filename of the index.json file (without its folder)
  force   = FORCE_DOWNLOAD,   # on/off. Force downloading even if the lang already exists at TARGET_DIR
  verbose = VERBOSE,          # (optional) on/off. Activate verbose messages of the process
  )

nim.get(
  dir     = TARGET_DIR,        # Path where the language will be installed
  M       = MAJOR_VERSION,     # Major version of Nim that will be compiled. Must have a valid branch named `version-M-m`
  m       = MINOR_VERSION,     # Minor version of Nim that will be compiled. Must have a valid branch named `version-M-m`
  force   = FORCE_COMPILATION, # (optional) on/off. Force downloading even if the lang already cloned+compiled into TARGET_DIR
  verbose = VERBOSE,           # (optional) on/off. Activate verbose messages of the process
  )

# Every function is commented with a short explanation of what it does.
# Refer to the comments of each module to understand how to use them in your own code.
```

> **Warning**:  
> `get.Lang` is not a toolchain versioning tool _(like `rustup`, `choosenim`, etc)_.  
> The default configuration works by installing languages to `CURRENTDIR/bin/.lang`  
> It can behave as a system-wide installation if you always set the `--trgDir` to the same folder for all your projects.  
> _eg: In your `$HOME/.lang` folder, or any other folder of your choosing_.  

### Alternative Installation (TBD)
`get.Lang` has a strong emphasis on not depending on existing toolchains being already installed on the system in order to bootstrap their tools.  
As such, this library provides a way to bootstrap itself.  

> **TBD**:  
> Not implemented yet.  
> The script will bootstrap nim to build get.Lang, and then build itself with ZigCC+Confy.  
> In the meantime, you can bootstrap nim+getlang manually with:  
> 1. Clone the Nim repo  
> 2. Run their `build_all` script  
> 3. Use the resulting nim/nimble binaries to build this app  

```md
# Requirements
git, gcc, (sh or powershell)

# Installation
git clone https://github.com/heysokam/get.Lang getlang
cd getlang
## Unix
sh ./init.ps1
## Windows
./init.ps1
```

## Won't support
`get.Lang` will never support languages that do not provide an easy way to create a `per-project` installation of its toolset, without depending on the language already being installed before-hand.  
_eg: Python_

