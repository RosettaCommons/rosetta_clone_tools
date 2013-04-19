rosetta_clone_tools
===================

A public repository with scripts and tools for cloning and setting up RosettaCommons repositories. 

get_rosetta.sh is a script which will download configure_rosetta_repo_.sh, and run it.  configure_rosetta_repo.sh will clone Rosetta, and copy the hooks in git_hooks into the new repository.

How to clone Rosetta
--------------------

```
curl -O https://raw.github.com/RosettaCommons/rosetta_clone_tools/master/get_rosetta.sh && bash get_rosetta.sh
```


will clone rosetta and set it up.  Follow all instructions when prompted by the script
