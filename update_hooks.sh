#!/bin/bash
# :noTabs=true:
# (c) Copyright Rosetta Commons Member Institutions.
# (c) This file is part of the Rosetta software suite and is made available
# (c) under license.
# (c) The Rosetta software is developed by the contributing members of the
# (c) Rosetta Commons.
# (c) For more information, see http://www.rosettacommons.org.
# (c) Questions about this can be addressed to University of Washington UW
# (c) TechTransfer, email: license@u.washington.edu.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Brief:   This shell script clones repositories from GitHub and configures   #
#          them to play nicely with how our community is organized.           #
#                                                                             #
# Note: Before you begin,                                                     #
#       1) Create a GitHub account and tell Andrew Leaver-Fay                 #
#          (aleaverfay@gmail.com) your GitHub user name so that he can        #
#          add you to the RosettaCommons account, and                         #
#       2) Set up SSH keys with GitHub following the                          #
#          instructions here                                                  #
#          https://help.github.com/articles/generating-ssh-keys               #
#                                                                             #
# Authors:  Brian D. Weitzner (brian.weitzner@gmail.com)                      #
#           Tim Jacobs (TimJacobs2@gmail.com)                                 #
#           Sam DeLuca (sam@decarboxy.com)                                    #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Global data
tools_url="https://github.com/RosettaCommons/rosetta_clone_tools/raw/master"
hook_url=$tools_url"/git_hooks"
hooks=(pre-commit post-commit prepare-commit-msg)

# Ensure the output is colorized to make it a little easier to read
color_echo="echo -e"

# Make sure the required arguments were supplied
if [ -z $1 ]; then
    $color-echo "\033[0;34mYou must pass the path of a git repository as the first argument to this script.\033[0m"
fi
repo=$1

# Make sure the supplied path is a git repository
if [ ! -e $repo/.git ]; then
    $color-echo "\033[0;34m$repo is not a git repository!\033[0m"
fi

starting_dir=$PWD

cd $repo/.git/hooks
for hook in "${hooks[@]}"; do 
    $color_echo  "\033[0;34mConfiguring the $hook hook...\033[0m"
    curl -kL $hook_url/$hook > $hook
    chmod +x $hook
done

cd $starting_dir
