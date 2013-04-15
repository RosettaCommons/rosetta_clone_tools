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
#       1) Create a github account and tell Andrew Leaver-Fay                 #
#          (aleaverfay@gmail.com) your github user name so that he can        #
#          add you to the RosettaCommons account, and                         #
#       2) set up ssh keys with github following the                          #
#          instructions here                                                  #
#          https://help.github.com/articles/generating-ssh-keys               #
#                                                                             #
# Author:  Brian D. Weitzner (brian.weitzner@gmail.com)                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Configuring the Rosetta GitHub repository on your machine."
echo "Make sure you have already"
echo "   1) created your github account"
echo "   2) emailed your github user name to Andrew Leaver-Fay (aleaverfay@gmail.com)"
echo "   3) set up ssh keys to github on your machine following the instructions here:"
echo "      https://help.github.com/articles/generating-ssh-keys"
echo "   4) to use HTTPS, follow the instructions for password caching here:"
echo "      https://help.github.com/articles/set-up-git"
echo
read -p "Please enter your GitHub username: " username
echo "\n"

# Pick a silly filename that had better not clobber something in your cwd.
tmp=$(date +%Y%m%d%H%M)
url=https://github.com/RosettaCommons/rosetta_clone_tools/raw/master
curl -L $url/configure_rosetta_repo.sh > $tmp && sh $tmp $username && rm $tmp