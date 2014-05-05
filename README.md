Rosetta Clone Tools
===================
### A public repository with scripts and tools for cloning and setting up RosettaCommons repositories. 

How to clone Rosetta
--------------------
```
curl -kL https://raw.github.com/RosettaCommons/rosetta_clone_tools/master/get_rosetta.sh > get_rosetta.sh && bash get_rosetta.sh
```
will clone rosetta and set it up.  Follow all instructions when prompted by the script

Brief descriptions of files in this repository
----------------------------------------------

###*get_rosetta.sh*###
A bash script that is used to get a copy of the Rosetta source code.
* Clones the Rosetta repositories (main, tools, demos)
* Copies the hooks in git_hooks into the new repositories
* Configures some useful git aliases
* Sets up a commit message template

###*update_hooks.sh*###
A script that downloads and places hooks into place.  The path to a git repository is required as an argument. Currently this sets up the following hooks:
* pre-commit
* post-commit
* prepare-commit-message

###*commit_template.txt*###
A commit message template that is used in the RosettaCommons. The template provides sections for: 
* A one-line description of changes
* A detailed description of changes
* The results of local testing
* Noting bug fixes 
* Explicitly requesting testing

###*git_hooks/pre-commit*###
This script is automatically executed before a `git-commit` is finalized.   
* Checks for large files being added to the repository and prompts the user for confirmation

###*git_hooks/post-commit*###
This script is automatically executed after a `git-commit` is finalized.
* Prompts the developer to track their branch if it is untracked 
* Reminds developer to push if there are >10 unpushed commits

###*git_hooks/prepare-commit-message*###
This script is automatically executed before a `git-commit` is finalized.
* Populates the commit message with the commit_template.txt
* Used on all commits, including merges
