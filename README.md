Rosetta Clone Tools
===================

This repo is a historical artifact of the previous way we recommended downloading Rosetta repositories when it was a private repo.

Now that the Rosetta repository is publically accessible, it is no longer needed.

How to clone Rosetta
--------------------

Rosetta can be downloaded from the Github repository at https://github.com/RosettaCommons/rosetta

We recommend using the same cloning proceedure you would use for any other Github repository.

If you're intending to develop Rosetta, please see the [Github Workflow](https://github.com/RosettaCommons/documentation/blob/master/internal_documentation/GithubWorkflow.md) documentation for further info.


Brief descriptions of files in this repository
----------------------------------------------

### *rosetta_compiler_test.py*

A utility script which allows you to test if your installed compiler is properly set up for the version of C++11 which Rosetta uses.
(Most default-installed C++ compilers in 2024 should be sufficent.)

### *other files*
These are remnants of the old way of setting up a Rosetta clone. They are unlikely to be of use, unless there's a particular configuration setting or git hook you want to resurrect.
