Rosetta Clone Tools
===================
### A public repository with scripts and tools for cloning and setting up RosettaCommons repositories. 

`get_rosetta.sh` is a script which will clone the Rosetta repositories (main, tools, demos), copy the hooks in git_hooks into the new repositories, configure some useful git aliases and set up a commit message template.

How to clone Rosetta
--------------------
```
curl -O https://raw.github.com/RosettaCommons/rosetta_clone_tools/master/get_rosetta.sh && bash get_rosetta.sh
```
will clone rosetta and set it up.  Follow all instructions when prompted by the script
