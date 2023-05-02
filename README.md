# Age of Wushu (North America) Files

This repository contains the decompiled lua scripts from Age of Wushu and other relevant packages that are extracted from the game.

Files will be separated by the game version in different folders to reference if there's any changes between patches.

## Relevant Versions

Version 363
- Current version of the game
- Version 357-363 are just minor hotfixes and does not contain much changes between them.

## FAQ

### How to unpack/repack manually from .package files?

Visit this [repository](https://github.com/ramazanaktolu/AOWPackageExtractor) and use that program to unpack/repack .package files.

### How to decompile .lua files?

Use [unluac](https://sourceforge.net/projects/unluac/) or another LUA 5.1 decompiler to decompile lua files found in lua.package. For CN/Taiwan servers, these files are now obfuscated as well, so you would have to either use older versions of the files or find a deobfuscator to read those files. However, ways people have gotten around this is by injecting and overwriting specific functions rather than modifying the entire file itself.