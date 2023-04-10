https://programmer.group/gcc-m-mm-mmd-mf-mt.html

for small projects the build system setup is fairly arbitrary. stuff everything into the same translation unit (i.e. concat sources) or don't, up to you.

for larger projects, that usually doesn't fly as compile times get long.
when everything is a separate TU, a change in a file corresponds to a change in one of the translation units...
however, this notwithstanding changes in files shared across translation units, 
such as headers, or other files that are not explicitly listed as dependencies. 
for this, the build system must need built-in support,
or you can ask the compiler to generate the list of files a file requires for compilation* 

you said earlier about linking the translation units directly, i.e. omitting -c, i wonder if gcc has a flag that would still emit the object files and link them together at the same time
`-c` just specifies to emit the object file(s) and not to run the linker
if you pass -o with it you will just specify the output path for said (single) object file 
i suppose gcc doesn't, at least not off a quick skim of man gcc... not that it needs it anyway.
it has enough switches as it is 

if you need to track dependencies between header files:
- clang and gccs `-MD` arg.
It'll output a list of headers so you can check timestamps against those
and know all the compilation units you need to rebuild
you may want to use `-MMD` instead, which omits #import `<thing.h>` headers 

