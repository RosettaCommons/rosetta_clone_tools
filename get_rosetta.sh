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
hooks=(pre-commit post-commit)
hook_url="https://github.com/RosettaCommons/rosetta_clone_tools/raw/master/git_hooks"

# If you'd only like one or two of the repositories, you can specify which one(s)
# on the command line.  Otherwise, all three will be cloned.
if [ -z $1 ]; then
    repos=(main rosetta_demos rosetta_tools)
else
    repos=("$@")
fi

# Ensure the output is colorized to make it a little easier to read
color_echo="echo -e"

# Prevent git from using a graphical password prompt
unset SSH_ASKPASS

main()
{
    $color_echo  "\033[0;32mConfiguring the Rosetta GitHub repository on your machine.\033[0m"
    $color_echo  "\033[0;34mMake sure you have already\033[0m"
    $color_echo  "\033[0;34m   1) created your GitHub account\033[0m"
    $color_echo  "\033[0;34m   2) emailed your GitHub user name to Andrew Leaver-Fay (aleaverfay@gmail.com)\033[0m"
    $color_echo  "\033[0;34m   3) Set up SSH keys to GitHub on your machine following the instructions here:\033[0m"
    $color_echo  "\033[0;34m      https://help.github.com/articles/generating-ssh-keys\033[0m"
    $color_echo  "\033[0;34m   4) to use HTTPS, follow the instructions for password caching here:\033[0m"
    $color_echo  "\033[0;34m      https://help.github.com/articles/set-up-git\033[0m"
    $color_echo 
    read -p "Please enter your GitHub username: " github_user_name
    $color_echo  "\n"

    read -p "Where would you like to clone Rosetta? The default is the current directory." path
    if [ -z $path ]; then
        path="."
    fi

    if [ ! -d $path ]; then
        $color_echo  "\033[0;33m'$path' does not exist!\033[0m You'll need to create '$path' if you want to install rosetta there."
        while true; do
            read -p "Would you like to create this directory now [y/n]? " yn
            case $yn in
                [Yy] | [Yy][Ee][Ss] ) mkdir $path; break;;
                [Nn] | [Nn][Oo] ) exit;;
            * ) $color_echo  "Please answer yes (y) or no (n).";;
            esac
        done
    fi  

    while true; do
        read -p "Would you like to clone over SSH (s) or HTTPS (h) - Note that SSH keys are required for cloning over SSH (Default: SSH)? " protocol
        case $protocol in
            [Ss] | [Ss][Ss][Hh] | "" ) url=git@github.com:RosettaCommons/; break;;
            [Hh] | [Hh][Tt][Tt][Pp][Ss] ) url=https://$github_user_name@github.com/RosettaCommons/; break;;
        *) $color_echo  "Please answer SSH (s) or HTTPS (h).";;
		esac	
    done
	
	while true; do
		read -p "Would you like to clone all 3 repositories in parallel? [y/n]? " yn
        case $yn in
            [Yy] | [Yy][Ee][Ss] ) parallel=true; break;;
            [Nn] | [Nn][Oo] ) parallel=false; break;;
        * ) $color_echo  "Please answer yes (y) or no (n).";;
        esac
    done

    if [ ! -d $path/Rosetta ]; then
        mkdir $path/Rosetta
    fi
    path="$path/Rosetta/"

    $color_echo  "\033[0;34mConfiguring...\033[0m"
    print_repo Super

    starting_dir=$PWD
    
    # Prevent the user from having to repeatedly enter his/her password
	git config --global credential.helper 'cache --timeout=3600'
	
	if $parallel; then
 	   for repo in "${repos[@]}"; do
        	(configure_repo $repo
        	cd $starting_dir) &
    	done
	else
  	   for repo in "${repos[@]}"; do
         	(configure_repo $repo
         	cd $starting_dir)
     	done
	fi
    
    wait
    $color_echo  "\033[0;32mDone configuring your Rosetta git repository!\033[0m"
}

configure_repo()
{
    hash git >/dev/null && /usr/bin/env git clone $url$1.git $path$1 || {
        $color_echo  "Can't clone! It's likely that git is not installed and/or you are cloning over SSH without SSH keys setup."
        $color_echo  "See https://help.github.com/articles/error-permission-denied-publickey for instructions on how to setup SSH keys for GitHub."
        exit
    }

    print_repo $1
    $color_echo  "\n\n \033[0;32m....is now cloned.\033[0m"

    cd $path/$1

    $color_echo  "\033[0;34mDisabling fast-forward merges on master...\033[0m"
    git config branch.master.mergeoptions "--no-ff"

    $color_echo  "\033[0;34mConfiguring commit message template...\033[0m"
    git config commit.template .commit_template.txt

    cd .git/hooks
    for hook in "${hooks[@]}"; do 
        $color_echo  "\033[0;34mConfiguring the $hook hook...\033[0m"
        curl -L $hook_url/$hook > $hook
        chmod +x $hook
    done

    cd ../..

    $color_echo  "\033[0;34mConfiguring aliases...\033[0m"
    git config alias.tracked-branch '!sh -c "git checkout -b $1 && git push origin $1:$2/$1 && git branch --set-upstream $1  origin/$2/$1" -'
    git config alias.personal-tracked-branch '!sh -c "git tracked-branch $1 $github_user_name" -'
    sed -ie "s/\$github_user_name/$github_user_name/g" .git/config

    git config alias.show-graph "log --graph --abbrev-commit --pretty=oneline"

    $color_echo  "\033[0;34mConfiguring git colors...\033[0m"
    git config color.branch auto
    git config color.diff auto
    git config color.interactive auto
    git config color.status auto
}

print_repo() 
{
    if [ $1 == "Super" ]; then
        $color_echo  "\033[0;32m"'     ___           ___           ___           ___           __         ___         ___      '"\033[0m"
        $color_echo  "\033[0;32m"'    /\  \         /\  \         /\__\         /\__\         /\__\      /\__\       /\  \     '"\033[0m"
        $color_echo  "\033[0;32m"'   /::\  \       /::\  \       /:/ _/_       /:/ _/_       /:/  /     /:/  /      /::\  \    '"\033[0m"
        $color_echo  "\033[0;32m"'  /:/\:\__\     /:/\:\  \     /:/ /\  \     /:/ /\__\     /:/__/     /:/__/      /:/\:\  \   '"\033[0m"
        $color_echo  "\033[0;32m"' /:/ /:/  /    /:/  \:\  \   /:/ /::\  \   /:/ /:/ _/_   /::\  \    /::\  \     /:/ /::\  \  '"\033[0m"
        $color_echo  "\033[0;32m"'/:/_/:/__/___ /:/__/ \:\__\ /:/_/:/\:\__\ /:/_/:/ /\__\ /:/\:\  \  /:/\:\  \   /:/_/:/\:\__\ '"\033[0m"
        $color_echo  "\033[0;32m"'\:\/:::::/  / \:\  \ /:/  / \:\/:/ /:/  / \:\/:/ /:/  / \/__\:\  \ \/__\:\  \  \:\/:/  \/__/ '"\033[0m"
        $color_echo  "\033[0;32m"' \::/~~/~~~~   \:\  /:/  /   \::/ /:/  /   \::/_/:/  /       \:\  \     \:\  \  \::/__/      '"\033[0m"
        $color_echo  "\033[0;32m"'  \:\~~\        \:\/:/  /     \/_/:/  /     \:\/:/  /         \:\  \     \:\  \  \:\  \      '"\033[0m"
        $color_echo  "\033[0;32m"'   \:\__\        \::/  /        /:/  /       \::/  /           \:\__\     \:\__\  \:\__\     '"\033[0m"
        $color_echo  "\033[0;32m"'    \/__/         \/__/         \/__/         \/__/             \/__/      \/__/   \/__/     '"\033[0m"

    elif [ $1 == "rosetta" ]; then
        $color_echo  "\033[0;32m"'      ___           ___                       ___      '"\033[0m"
        $color_echo  "\033[0;32m"'     /\  \         /\  \                     /\  \     '"\033[0m"
        $color_echo  "\033[0;32m"'    |::\  \       /::\  \       ___          \:\  \    '"\033[0m"
        $color_echo  "\033[0;32m"'    |:|:\  \     /:/\:\  \     /\__\          \:\  \   '"\033[0m"
        $color_echo  "\033[0;32m"'  __|:|\:\  \   /:/ /::\  \   /:/__/      _____\:\  \  '"\033[0m"
        $color_echo  "\033[0;32m"' /::::|_\:\__\ /:/_/:/\:\__\ /::\  \     /::::::::\__\ '"\033[0m"
        $color_echo  "\033[0;32m"' \:\~~\  \/__/ \:\/:/  \/__/ \/\:\  \__  \:\~~\~~\/__/ '"\033[0m"
        $color_echo  "\033[0;32m"'  \:\  \        \::/__/       ~~\:\/\__\  \:\  \       '"\033[0m"
        $color_echo  "\033[0;32m"'   \:\  \        \:\  \          \::/  /   \:\  \      '"\033[0m"
        $color_echo  "\033[0;32m"'    \:\__\        \:\__\         /:/  /     \:\__\     '"\033[0m"
        $color_echo  "\033[0;32m"'     \/__/         \/__/         \/__/       \/__/     '"\033[0m"

    elif [ $1 == "rosetta_demos" ]; then
        $color_echo  "\033[0;32m"'                    ___           ___           ___           ___      '"\033[0m"
        $color_echo  "\033[0;32m"'     _____         /\__\         /\  \         /\  \         /\__\     '"\033[0m"
        $color_echo  "\033[0;32m"'    /::\  \       /:/ _/_       |::\  \       /::\  \       /:/ _/_    '"\033[0m"
        $color_echo  "\033[0;32m"'   /:/\:\  \     /:/ /\__\      |:|:\  \     /:/\:\  \     /:/ /\  \   '"\033[0m"
        $color_echo  "\033[0;32m"'  /:/  \:\__\   /:/ /:/ _/_   __|:|\:\  \   /:/  \:\  \   /:/ /::\  \  '"\033[0m"
        $color_echo  "\033[0;32m"' /:/__/ \:|__| /:/_/:/ /\__\ /::::|_\:\__\ /:/__/ \:\__\ /:/_/:/\:\__\ '"\033[0m"
        $color_echo  "\033[0;32m"' \:\  \ /:/  / \:\/:/ /:/  / \:\~~\  \/__/ \:\  \ /:/  / \:\/:/ /:/  / '"\033[0m"
        $color_echo  "\033[0;32m"'  \:\  /:/  /   \::/_/:/  /   \:\  \        \:\  /:/  /   \::/ /:/  /  '"\033[0m"
        $color_echo  "\033[0;32m"'   \:\/:/  /     \:\/:/  /     \:\  \        \:\/:/  /     \/_/:/  /   '"\033[0m"
        $color_echo  "\033[0;32m"'    \::/  /       \::/  /       \:\__\        \::/  /        /:/  /    '"\033[0m"
        $color_echo  "\033[0;32m"'     \/__/         \/__/         \/__/         \/__/         \/__/     '"\033[0m"
        
    elif [ $1 == "rosetta_tools" ]; then
        $color_echo  "\033[0;32m"'      ___           ___           ___                           ___      '"\033[0m"
        $color_echo  "\033[0;32m"'     /\__\         /\  \         /\  \                         /\__\     '"\033[0m"
        $color_echo  "\033[0;32m"'    /:/  /        /::\  \       /::\  \     ___               /:/ _/_    '"\033[0m"
        $color_echo  "\033[0;32m"'   /:/__/        /:/\:\  \     /:/\:\  \   /\  \             /:/ /\  \   '"\033[0m"
        $color_echo  "\033[0;32m"'  /::\  \       /:/  \:\  \   /:/  \:\  \  \:\  \     ___   /:/ /::\  \  '"\033[0m"
        $color_echo  "\033[0;32m"' /:/\:\  \     /:/__/ \:\__\ /:/__/ \:\__\  \:\  \   /\__\ /:/_/:/\:\__\ '"\033[0m"
        $color_echo  "\033[0;32m"' \/__\:\  \    \:\  \ /:/  / \:\  \ /:/  /   \:\  \ /:/  / \:\/:/ /:/  / '"\033[0m"
        $color_echo  "\033[0;32m"'      \:\  \    \:\  /:/  /   \:\  /:/  /     \:\  /:/  /   \::/ /:/  /  '"\033[0m"
        $color_echo  "\033[0;32m"'       \:\  \    \:\/:/  /     \:\/:/  /       \:\/:/  /     \/_/:/  /   '"\033[0m"
        $color_echo  "\033[0;32m"'        \:\__\    \::/  /       \::/  /         \::/  /        /:/  /    '"\033[0m"
        $color_echo  "\033[0;32m"'         \/__/     \/__/         \/__/           \/__/         \/__/     '"\033[0m"
    
    fi

    $color_echo 
}

main
