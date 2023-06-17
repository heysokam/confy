# Details about the Internal design and features of Confy

## Why zig cc by default?
Must watch: [zig cc Introduction](https://youtu.be/YXrb-DqsBNU?t=460)

The zig compiler is standalone, and **platform independent**.  
When using gcc, you need to rely on mingw in both windows/linux to do whatever cross-compilation tasks you need to do.  
Again, complicating the buildsystem by a LOT, and forcing you to code explicit code for all the systems that you might encounter.  

While with `zig cc`, you can just say `-target=linux` from a windows computer _(or any obscure system, really. their platform support is crazy)_...  
and it will cross-compile as if cross compiling for that system was just a normal thing _(as it should be)_.

There is also the fact that the zig compiler is **self-contained**, and fits in a 40mb download.  
So confy just downloads it automatically, and keeps it up to date, with just a few tens of lines of internal code...  
removing the need for installing a compiler at all,  
something that causes a huge amount of friction when it comes to setting up a project.  
_(eg: like installing mingw on windows, or msvc, as a casual or new programmer with not much experience yet)_  

These two features make `zig cc` a much better fit for a default compiler for a simple and cross-platform buildsystem...  
where things are expected to #JustWork without writing hundreds of lines of boilerplate setup, that must be repeated for every new project.  

That being said, you can still use `gcc` or `clang` if you wanted to,  
since this buildsystem is just a way to automate a sequence of console commands.  
It's just that `zig cc` fits the project better for a **default** when not explicitely changed.  


## Why not use the existing zig buildsystem features?
Because that would make the buildsystem a zig-based one,  
where you have to add code for your build using the zig lang.  
_See their `build.zig` files for reference__

While Zig is great, it is still a very unintuitive language. Just like C and C++ are.  
You can learn them? yes, absolutely. And you will eventually write them as if they were your mother language.
But that doesn't mean they are easy to pick up, or fast to prototype with.  

Nim, on the other hand, has the most clean and minimal syntax for all static-typed languages I know.  
And the goal of this buildsystem is to keep the buildsystem stuff -simple-, clean and intuitive.  
It should be, and stay, out of the damn way, so you can code other things that matter a whole lot more than a buildsystem.  

Nobody wants to invest a week _(or possibly more)_ learning a new language just to setup their damn project.  
So, I think Nim is the perfect choice for that. Even better than python.  


## Why not python
Nim is its just as easy to learn as python, but you cannot shoot yourself by accident.  
In python there is no compiler warning you about your mistakes. If you make a mess, good luck trying to find where it is.  
While Nim is just C in the background, so you can even step through a debugger to see where things went wrong.  
And the compiler has your back when it comes to syntax mistakes.  

Python modules are also a mess to setup. The whole `__init.py__` and `when __name__ == "main":` thing is just ridiculous.  
Every type being just a string is also a big issue. I spent so much time trying to write type-checks in my functions/classes,  
where the compiler/interpreter of the lang should have already being doing that by default.
Classes are fine for small things. But they scale really really badly for big projects.  

Also, spend a few months working with nim's stdlib... and compare it to python after that.  
I literally threw away hundreds and hundreds of lines of code for doing simple things that should be part of the python stdlib, as soon as I moved to Nim.

If you want a simple api for even basic system management tasks, with python you are either on your own...  
... or you need to spend a lot of time searching for, and depending on, libraries that do those simple basic things.  
While in Nim, the stdlib just works, and its api is already very minimal and clean, without needing any customizations built on top.  
I found very very few things that I thought should be part of the nim's std library, and are not there already.

This is not a hate on Python, don't get me wrong. I really love python, and use it regularly.  
Python is a great language and ecosystem for what it is.  

But if the goal is to make a -simple- buildsystem, that scales well for complex/intricate projects...
_(as complex as a game engine with multiple games, forks and mods, like any of the Quake engines)_,
those things I mentioned are huge dealbreakers.  

> Right tool for the right job.  

I love scons and python. I just don't love python as a language for a buildsystem...  
after spending two months implementing one for the Quake3 engine.  
That's all really.  
Right tool for the right job :shrug:  

