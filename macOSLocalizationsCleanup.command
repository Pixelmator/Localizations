#!/bin/sh

SOURCEDIR="$( cd "$( dirname "$0" )" && pwd )"

ENLOCALIZATIONDIR="$SOURCEDIR/macOS/en.lproj"

LOCALIZATIONDIR="$SOURCEDIR/macOS"
for entry in "$LOCALIZATIONDIR"/*
do
  if [ "$entry" != "$ENLOCALIZATIONDIR" ]; then
    for entry in "$entry"/*
    do
       filename="${entry##*/}"
       searchresult=$(find $ENLOCALIZATIONDIR -name "$filename")
       if [ "$searchresult" == "" ]; then
        rm "$entry"
       fi
    done
  fi
done