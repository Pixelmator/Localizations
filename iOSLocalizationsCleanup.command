#!/bin/sh

# Set directory of the script as current directory
cd "$(dirname "$0")"

# find .lproj directories
for directory in "iOS/*.lproj"; do
    # find all files with PXTKit prefix
    for file in $directory/PXTKit*; do
        # move in to PXTKit framework
        mv -f $file ../../iOS/PXTKit/PXTKit/Localizations/$file
    done
done
