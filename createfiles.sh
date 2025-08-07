#!/bin/bash

# Description: This script is used by ChatGPT to create new files and run any terminal commands needed during the site development process.
# Files will only be created if they do not already exist.
# Each new file created will start with a one-line description of its purpose and an instruction to open it in VSCode in a new split window so ChatGPT can edit it.
# After completing its tasks, this script will update filelist.txt by preserving the first line (description header) and replacing the rest with an up-to-date sorted list of all other files.



echo "Updating filelist.txt..."
head -n 5 filelist.txt > temp_filelist.txt
find . -type f ! -name "filelist.txt" ! -name ".DS_Store" | sort >> temp_filelist.txt
mv temp_filelist.txt filelist.txt
echo "filelist.txt updated."