rosetta_clone_tools
===================

A public repository with scripts and tools for cloning and setting up RosettaCommons repositories. 

get_rosetta.sh is a script which will download configure_rosetta_repo_.sh, and run it.  configure_rosetta_repo.sh will clone Rosetta, and copy the hooks in git_hooks into the new repository.

How to clone Rosetta
--------------------

`
curl -o get_rosetta.sh https://raw.github.com/RosettaCommons/rosetta_clone_tools/master/get_rosetta.sh

chmod +x get_rosetta.sh

./get_rosetta.sh rosetta/
`

will clone rosetta into a new directory called 'rosetta/'  You can clone into any directory this way. 
