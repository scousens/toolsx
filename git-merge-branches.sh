#! /bin/bash -x

src_branch=$1
dst_branch=$2

src_branch=master
dst_branch=feature/python3
echo "src_branch=$src_branch"
echo "dst_branch=$dst_branch"

# remove / from src/dst branch names so we only have 1 slash in the resulting temp branch
tmp_branch="merge-${src_branch//\//_}-into-${dst_branch//\//_}-mmp"
# mmp start with master, merge in python3   | base is master

# update our versions of source/destination
git fetch origin
#git checkout $src_branch
#git pull
#git checkout $dst_branch 
#git pull

# cleanup/delete any temp leftovers - forcibly
echo
git branch -d -f $USER/$tmp_branch

git checkout -b $USER/$tmp_branch origin/$src_branch
git merge origin/$dst_branch -m "Merge remote-tracking branch $src_branch into $dst_branch"
#git checkout -b $USER/$tmp_branch origin/$dst_branch
#git merge origin/$src_branch -m "Merge remote-tracking branch $src_branch into $dst_branch"

echo
echo "checking"
git status -uno | grep -q -e "both " 
if [ $? -eq 0 ]; then
	echo "Deal with conflicts"
	exit 1
else
    echo "This looks like a clean merge. You can proceed...."
fi

# Deal with any conflicts if they exist and then do:
# - git add .
# - git merge --continue
# - git commit (use already filled in commit message)

# once merge is ready, all conflicts addressed push
#git push origin $USER/$tmp_branch
# Open a PR 

# once there are enough approvals, add 'fastforward' label to the PR - this will 
# merge the PR (assuming all checks are complete)

