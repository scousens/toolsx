#! /bin/bash
# use this with git-recursive-op.sh for the full recursive check.
#  usage: git-recursive-op.sh kill-enlistment.sh
#         kill-enlistment.sh
#
# if the directory (tree) is clean - it will continue. Eise it should stop with # issues found


function checkit()
{
issue=0
GIT_STASHES=0
# updated/new/modified files in working tree
if output=$(git status --untracked-files=no --porcelain) && [ -z "$output" ]; then 
  # Working directory clean excluding untracked files
  GIT_CLEAN=1
else 
	GIT_CLEAN=0
	GIT_DIRTY=$output
	issue=1
fi
# stashes
if git rev-parse --verify --quiet refs/stash >/dev/null 2>/dev/null; then
	GIT_CLEAN=0
	GIT_STASHES=1
	issue=1
fi
if [ "$GIT_CLEAN" -eq 1 ]; then
	echo GIT is CLEAN
else
	echo Directory is DIRTY
	if [ ! -z "$GIT_DIRTY" ]; then
		echo "Have changes"
	fi
	if [ "$GIT_STASHES" -eq 1 ]; then
		echo "Have stashed items"
	fi
fi
issues=$((issues+issue))
}

issues=0
dr="$1"
if [[ -z "$dr" ]]; then
	dr='.'
fi
cd $dr
echo $(pwd)

## git status check
cb=`git branch --list | grep '\*' | sed -e 's/\*/ /'`
echo "--$cb--"
checkit

## git non-merged branches 
issue=0
br=`git branch --list --no-merged | sed -e 's/\*/ /'`
for i in ${br[@]}; do
  echo "--$i-- not merged"
 issue=$((issue+1))
done
if [[ $issue -gt 0 ]]; then
	echo "GIT has unmerged branches here!"
fi
issues=$((issues+issue))

## vagrant check - any VMs off here?
if [ -e Vagrantfile ]; then
	vagrant status | grep -E '(poweroff)|(running)'
	if [[ $? -eq 0 ]]; then
		issues=$((issues+1))
		echo "We have a VAGRANT VM here!"
	fi
fi

echo "Ran into $issues issues total"
exit $issues
