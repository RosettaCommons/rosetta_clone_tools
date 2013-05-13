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

# Ensure the output is colorized to make it a little easier to read
color_echo="echo -e"

# Make sure the required arguments were supplied
if [ -z $1 ]; then
    $color-echo "\033[0;34mYou must pass the path of a git repository as the first argument to this script.\033[0m"
fi

if [ -z $1 ]; then
    $color-echo "\033[0;34mYou must pass your GitHub username as the second argument to this script.\033[0m"
fi

repo=$1
github_user_name=$2

# Make sure the supplied path is a git repository
if [ ! -e $repo/.git ]; then
    $color-echo "\033[0;34m$repo is not a git repository!\033[0m"
fi

starting_dir=$PWD

cd $repo

$color_echo  "\033[0;34mConfiguring aliases...\033[0m"
git config alias.tracked-branch '!sh -c "git checkout -b $2/$1 && git push origin $2/$1:$2/$1 && git branch --set-upstream $2/$1  origin/$2/$1" -'
git config alias.personal-tracked-branch '!sh -c "git tracked-branch $1 $github_user_name" -'
sed -ie "s/\$github_user_name/$github_user_name/g" .git/config

git config alias.show-graph "log --graph --abbrev-commit --pretty=oneline"

$color_echo  "\033[0;34mConfiguring git colors...\033[0m"
git config color.branch auto
git config color.diff auto
git config color.interactive auto
git config color.status auto

$color_echo "\033[0;34mConfiguring git push to only push the current branch...\033[0m"
git config push.default current

cd $starting_dir
