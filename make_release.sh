#!/bin/bash

# works with a file called VERSION in the current directory, the contents of 
# which should be a semantic version number such as "1.2.3" or "4.5.6-alpha"

# this script will display the current version, automatically suggest a "minor"
# version update (if the current version has no label otherwise, it will just
# remove the current label to stabilize the version), and ask for input to use
# the suggestion, or a newly entered value.

# once the new version number is determined, the script will pull a list of
# changes from git history, prepend this to a file called CHANGELOG (under the
# title of the new version number) and create a GIT tag.

# Checking if local git repository is clean before relase.
GIT_LOCAL_CHANGES=$(git status --porcelain 2> /dev/null)
[[ $(echo $GIT_LOCAL_CHANGES | tail -n1) != "" ]] && \
  echo -e "error: Your local changes to the following files would impact the release:\n$GIT_LOCAL_CHANGES\nPlease, commit your changes or stash them before you can release." && \
	exit 1

if [ -f VERSION ]; then
    BASE_STRING=`cat VERSION`
    BASE_LIST=(`echo $BASE_STRING | tr '.-' ' '`)
    V_MAJOR=${BASE_LIST[0]}
    V_MINOR=${BASE_LIST[1]}
    V_PATCH=${BASE_LIST[2]}
    V_LABEL=${BASE_LIST[3]}
    echo "Current version : $BASE_STRING"
    
    if [ "$@" = "" ] || [ "$@" = "-h" ] || [ "$@" = "--help" ]; then echo -e "usage: sh ./make_release.sh <major|minor|patch>"; fi
    if [ "$@" = "major" ]; then V_MAJOR=$((V_MAJOR + 1)); V_MINOR=0; V_PATCH=0; fi
    if [ "$@" = "minor" ]; then V_MINOR=$((V_MINOR + 1)); V_PATCH=0; fi
    if [ "$@" = "patch" ] && [ "$V_LABEL" = "" ]; then V_PATCH=$((V_PATCH + 1)); fi
    SUGGESTED_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
    
	echo "You are about to release the following version: $SUGGESTED_VERSION"
	read -p "Do you wish to continue? [y/N]: " RESPONSE
	if [ "$RESPONSE" = "" ]; then RESPONSE="n"; fi
    if [ "$RESPONSE" = "Y" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "Yes" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "yes" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "YES" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "y" ]; then
      
      INPUT_VERSION=$SUGGESTED_VERSION
      LASTEST_TAG=`git describe --tags $(git rev-list --tags --max-count=1)`
      echo $INPUT_VERSION > VERSION
      echo "Version $INPUT_VERSION:" > tmpfile
      git log --pretty=format:" - %s" $LASTEST_TAG...HEAD >> tmpfile
      echo "" >> tmpfile
      echo "" >> tmpfile
      cat CHANGELOG >> tmpfile
      mv tmpfile CHANGELOG
      
      NEXT_BASE_LIST=(`echo $INPUT_VERSION | tr '.-' ' '`)
      NEXT_V_MAJOR=${NEXT_BASE_LIST[0]}
      NEXT_V_MINOR=${NEXT_BASE_LIST[1]}
      NEXT_V_PATCH=${NEXT_BASE_LIST[2]}
      NEXT_DEV_VERSION="$NEXT_V_MAJOR.$NEXT_V_MINOR.$((NEXT_V_PATCH + 1))-DEV"
      echo "Will set next development version to be $NEXT_DEV_VERSION"
      
      git add CHANGELOG VERSION
      git commit -m "Version bump to $INPUT_STRING  [ci skip]"
      git tag -a -m "Tagging version $INPUT_STRING" "v$INPUT_VERSION"
      echo $NEXT_DEV_VERSION > VERSION
      git add VERSION
      git commit -m "Version bump to $NEXT_DEV_VERSION [ci skip]"
      git push origin master "v$INPUT_VERSION"
  fi
else
	echo "Could not find a VERSION file"
    read -p "Do you want to create a version file and start from scratch? [Y/n]: " RESPONSE
    if [ "$RESPONSE" = "" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "Y" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "Yes" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "yes" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "YES" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "y" ]; then
        
        echo "0.1.0" > VERSION
        echo "Version 0.1.0" > CHANGELOG
        git log --pretty=format:" - %s" >> CHANGELOG
        echo "" >> CHANGELOG
        echo "" >> CHANGELOG
        
        git add VERSION CHANGELOG
        git commit -m "Added VERSION and CHANGELOG files, Version bump to 0.1.0 [ci skip]"
        git tag -a -m "Tagging version 0.1.0" "v0.1.0"
        echo "0.1.1-DEV" > VERSION
        git add VERSION
        git commit -m "Version bump to 0.1.1-DEV [ci skip]"
        git push origin master v0.1.0
    fi
fi
