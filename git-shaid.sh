#! /bin/bash

GIT_SHA=$1
#set GIT_TAG_NAME to our desired build so it can be used correctly in run-jenkins.sh
if test ! ${GIT_SHA}; then
    echo "No GIT_SHA provided."
    exit 1
fi

# if we are given a tag...
if test $(git tag -l ${GIT_SHA}); then
    echo "${GIT_SHA} is a TAG"
fi
# is it a branch
BR=`git branch -a --contains ${GIT_SHA} | head -n1`
if test -n "$BR"; then
    echo "${GIT_SHA} points to branch: ${BR[0]}"
fi
BR=`git name-rev --name-only ${GIT_SHA}`
if test -n "$BR"; then
    echo "${GIT_SHA} represents ${BR}"
fi

if test -n ""; then
    # if we are given a tag - use that as the name
    TAG_NAME=`git tag -l ${GIT_SHA}`
    if [ -z ${TAG_NAME} ]; then 
        # not a tag - get the branch we checked out
        BR=`git describe --all`
        if [ $? != 0 ]; then
            exit 1
        fi
        HEAD=`git rev-parse ${BR}^{commit}`
        # if checked out commit matches what we have its a git sha - use as-is
        if [ "${GIT_SHA}" = "${HEAD}" ]; then
            PKG_NAME="${GIT_SHA} [sha]"
        else
            # its a branch - use it as is (or w/ -BUILD_NUMBER, or ???)
            PKG_NAME="${GIT_SHA} [branch]"
        fi
    fi
    echo "--BuildID = ${PKG_NAME}"
fi
