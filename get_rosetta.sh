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
#       1) Sign the developers' agreement and have your PI email Oriel        #
#          Goldstein (oriel.goldstein@mail.huji.ac.il) granting you explicit  #
#          read and/or write access.  See the wiki for details.               #
#       2) Create a GitHub account and tell Oriel Goldstein                   #
#          (oriel.goldstein@mail.huji.ac.il) your GitHub user name            #
#          so that he can add you to the RosettaCommons account, and          #
#       3) Set up SSH keys with GitHub following the                          #
#          instructions here                                                  #
#          https://help.github.com/articles/generating-ssh-keys               #
#                                                                             #
# Authors:  Brian D. Weitzner (brian.weitzner@gmail.com)                      #
#           Tim Jacobs (TimJacobs2@gmail.com)                                 #
#           Sam DeLuca (sam@decarboxy.com)                                    #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Global data
tools_url="https://github.com/RosettaCommons/rosetta_clone_tools/raw/master"
update_hooks="update_hooks.sh"
update_config="update_config.sh"
commit_template="commit_template.txt"

# Ensure the output is colorized to make it a little easier to read
color_echo="echo -e"

# If you'd only like one or two of the repositories, you can specify which one(s)
# on the command line.  Otherwise, all three will be cloned.
if [ -z $1 ]; then
    repos=(main demos tools documentation)
else
    repos=("$@")
fi

# Prevent git from using a graphical password prompt
unset SSH_ASKPASS

main()
{
    $color_echo  "\033[0;32mConfiguring the Rosetta GitHub repository on your machine.\033[0m"
    $color_echo  "\033[0;32mThe following repositories will be cloned:\033[0m"
    for repo in "${repos[@]}"; do
        $color_echo  "\033[0;32m  - ${repo}\033[0m"
    done
    $color_echo  "\033[0;32mTo specify specific repositories, pass them as arguments to this script\033[0m"
    $color_echo  "\033[0;32m\033[0m"

    $color_echo  "\033[0;34mMake sure you have already:\033[0m"
    $color_echo  "\033[0;34m   1)  Signed the developer agreement,\033[0m"
    $color_echo  "\033[0;34m   2)  Created your GitHub account,\033[0m"
    $color_echo  "\033[0;34m   3)  Emailed your GitHub user name to Oriel Goldstein (oriel.goldstein@mail.huji.ac.il),\033[0m"
    $color_echo  "\033[0;34m   4a) Set up SSH keys to GitHub on your machine following the instructions here:\033[0m"
    $color_echo  "\033[0;34m       https://help.github.com/articles/generating-ssh-keys\033[0m"
    $color_echo  "\033[0;34m   4b) Or, to use HTTPS, followed the instructions for password caching here:\033[0m"
    $color_echo  "\033[0;34m       https://help.github.com/articles/set-up-git\033[0m"
    $color_echo 
    read -p "Please enter your GitHub username: " github_user_name
    $color_echo  "\n"
    while true; do
        read -p "Are you creating a new clone [y/n]? " yn
        case $yn in
            [Yy] | [Yy][Ee][Ss] ) clone=1; break;;
            [Nn] | [Nn][Oo] ) clone=0; break;;
        * ) $color_echo  "Please answer yes (y) or no (n).";;
        esac
    done
    
    if [[ clone -eq 1 ]]; then
        clone_hooks_config
    else
      hooks_config
    fi

    $color_echo  "\033[0;34mConfiguring your global line endings settings to play nicely with everyone...\033[0m"
    if [[ `uname` == "Linux" || `uname` == "Darwin" ]]; then 
    	# Set this setting on OS X or Linux
    	git config --global core.autocrlf input
    else
    	# Set this setting on Windows
    	git config --global core.autocrlf true
    fi
    
    $color_echo  "\033[0;34mDeleting update_hooks script...\033[0m"
    rm $path/$update_hooks
    
    $color_echo  "\033[0;34mDeleting update_config script...\033[0m"
    rm $path/$update_config
    
    $color_echo  "\033[0;34mDeleting the get_rosetta script...\033[0m"
    rm get_rosetta.sh
    
    $color_echo  "\033[0;32mDone configuring your Rosetta git repository!\033[0m"
}

hooks_config()
{
    read -p "Where is your copy of Rosetta? The default is the current directory (i.e. ./Rosetta exits): " path
    if [ -z $path ]; then
        path="."
    fi

    if [ ! -d $path ]; then
        $color_echo  "\033[0;33m'$path' does not exist!\033[0m You'll need to create '$path' if you want to install rosetta there."
        exit
    fi  

    download_helper_scripts
	
  	for repo in "${repos[@]}"; do
        (cd $path/$repo
        print_repo $repo
        bash ../$update_hooks .
        bash ../$update_config . $github_user_name
        cd $starting_dir)
    done
}

clone_hooks_config()
{
    read -p "Where would you like to clone Rosetta? The default is the current directory: " path
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
		read -p "Would you like to clone all repositories in parallel? [y/n]? " yn
        case $yn in
            [Yy] | [Yy][Ee][Ss] ) parallel=true; break;;
            [Nn] | [Nn][Oo] ) parallel=false; break;;
        * ) $color_echo  "Please answer yes (y) or no (n).";;
        esac
    done

    if [ ! -d $path/Rosetta ]; then
        mkdir $path/Rosetta
    fi
    
    download_helper_scripts
    
    # Prevent the user from having to repeatedly enter his/her password
	git config --global credential.helper 'cache --timeout=3600'
	
	if $parallel; then
 	   for repo in "${repos[@]}"; do
        	(configure_repo $repo
        	bash ../$update_hooks .
        	bash ../$update_config . $github_user_name
        	cd $starting_dir) &
    	done
	else
  	   for repo in "${repos[@]}"; do
         	(configure_repo $repo
         	bash ../$update_hooks .
        	bash ../$update_config . $github_user_name
         	cd $starting_dir)
     	done
	fi
    
    wait
}

download_helper_scripts() {
    path="$path/Rosetta/"

    $color_echo  "\033[0;34mConfiguring...\033[0m"
    print_repo Super

    starting_dir=$PWD
    
    $color_echo  "\033[0;34mDownloading commit message template...\033[0m"
    curl -kL $tools_url/$commit_template > $path/.$commit_template
    
    $color_echo  "\033[0;34mDownloading update_hooks script...\033[0m"
    curl -kL $tools_url/$update_hooks > $path/$update_hooks
    
    $color_echo  "\033[0;34mDownloading update_config script...\033[0m"
    curl -kL $tools_url/$update_config > $path/$update_config
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

    elif [ $1 == "main" ]; then
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

    elif [ $1 == "demos" ]; then
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
        
    elif [ $1 == "tools" ]; then
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
    
    elif [ $1 == "documentation" ]; then
        $color_echo  "\033[0;32m"'                    ___           ___           ___      '"\033[0m"
        $color_echo  "\033[0;32m"'     _____         /\  \         /\__\         /\__\     '"\033[0m" 
        $color_echo  "\033[0;32m"'    /::\  \       /::\  \       /:/  /        /:/ _/_    '"\033[0m"
        $color_echo  "\033[0;32m"'   /:/\:\  \     /:/\:\  \     /:/  /        /:/ /\  \   '"\033[0m"
        $color_echo  "\033[0;32m"'  /:/  \:\__\   /:/  \:\  \   /:/  /  ___   /:/ /::\  \  '"\033[0m"
        $color_echo  "\033[0;32m"' /:/__/ \:|__| /:/__/ \:\__\ /:/__/  /\__\ /:/_/:/\:\__\ '"\033[0m"
        $color_echo  "\033[0;32m"' \:\  \ /:/  / \:\  \ /:/  / \:\  \ /:/  / \:\/:/ /:/  / '"\033[0m"
        $color_echo  "\033[0;32m"'  \:\  /:/  /   \:\  /:/  /   \:\  /:/  /   \::/ /:/  /  '"\033[0m" 
        $color_echo  "\033[0;32m"'   \:\/:/  /     \:\/:/  /     \:\/:/  /     \/_/:/  /   '"\033[0m"
        $color_echo  "\033[0;32m"'    \::/  /       \::/  /       \::/  /        /:/  /    '"\033[0m"
        $color_echo  "\033[0;32m"'     \/__/         \/__/         \/__/         \/__/     '"\033[0m"

    fi

    $color_echo 
}

main
