#! /bin/bash

echo """Update a feature branch with base branch.

Merge base/source branch into feature branch, keeping source as base
Usage:
	$0 <source_branch> <destination_branch>
"""

src_branch=$1
dst_branch=$2

# src_branch=master
# dst_branch=feature/python3
echo "src_branch=$src_branch"
echo "dst_branch=$dst_branch"

# remove / from src/dst branch names so we only have 1 slash in the resulting temp branch
tmp_branch="merge-${src_branch//\//_}-into-${dst_branch//\//_}-tmp"
# mmp start with master, merge in python3   | base is master

echo "Tmp branch=$tmp_branch"
read -p "Continue? (yN) " yn
if [ "${yn}" != "y" ]; then
    echo "Bailing out. (did not respond with 'y')"
    exit
fi

set -x
# update our versions of source/destination
git fetch origin
#git checkout $src_branch
#git pull
#git checkout $dst_branch 
#git pull

# cleanup/delete any temp leftovers - forcibly
echo
echo "Cleanup our branch [$USER/$tmp_branch]"
git branch -d -f $USER/$tmp_branch

echo
echo "create temp merge branch"
# updating feature branch: start with base branch, merge in feature branch
git checkout --no-track -b $USER/$tmp_branch origin/$src_branch
git merge origin/$dst_branch -m "Merge remote-tracking branch $src_branch into $dst_branch" | tee merge-output.txt
#git checkout -b $USER/$tmp_branch origin/$dst_branch
#git merge origin/$src_branch -m "Merge remote-tracking branch $src_branch into $dst_branch"

set +x
echo
echo "checking"
git status -uno | grep -q -e "both " 
if [ $? -eq 0 ]; then
    echo "Deal with conflicts"
    retcode=1
    #exit 1
else
    echo "This looks like a clean merge. You can proceed...."
    retcode=0
fi

# Deal with any conflicts if they exist and then do:
# - git add .
# - git merge --continue
# - git commit (use already filled in commit message)

# python3 PR: [UNTY-66237] master into feature python3

echo
echo "# once merge is ready, all conflicts addressed push"
echo " git push  --set-upstream origin $USER/$tmp_branch"
echo
echo "# Open a PR "
echo "## put 'cat merge-output.txt' into PR description"
echo

echo "# once there are enough approvals, add 'fastforward' label to the PR - this will "
echo "# merge the PR (assuming all checks are complete)"

if [ $retcode -ne 0 ]; then
	echo
    echo "WARNING: merge was NOT clean! deal with conflicts; fixup merge before proceeding....."
    echo
    exit 1
fi
