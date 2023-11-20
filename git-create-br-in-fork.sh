#! /bin/bash -xe

HT="Pull branch from UPSTREAM and create in workspace and ORIGIN.

Create a new <branch> in workspace and on origin and base off upstream/<basebranch>
Assumes ORIGIN and UPSTREAM as remotes

Usage: ${0} <branch> <basebranch>
"

if [ "${1}" == "-h" ]; then
	echo "${HT}"
	exit 1
fi
if [ -z "${1}" ]; then
	echo "You must specify the name of a branch to create"
	echo "${HT}"
	exit 1
fi
if [ -z "${2}" ]; then
	echo "You must specify the base branch from which to create this branch (master, develop etc)"
	echo "${HT}"
	exit 1
fi
BRANCH="${1}"
BASE="${2}"

#validate branch:
git branch -r | grep "upstream/${BASE}"
if [ $? -gt 0 ]; then
	echo "Unable to validate base branch ${BASE} off upstream"
	exit 1
fi
echo "---Good to GO"
echo

echo "---create branch in ORIGIN repo; create/checkout w/ tracking branch"
git push origin origin/"${BASE}":refs/heads/"${BRANCH}" && git checkout --track -b "${BRANCH}" origin/"${BRANCH}" && git status | grep "Your branch"
if [ $? -gt 0 ]; then
	echo "OOOOPS"
	exit 1
fi

#while true; do
#    read -p "Rebase and push (from ${BASE})?" yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
echo "---fetch and rebase from UPSTREAM repo; push to ORIGIN"
git fetch upstream
git rebase upstream/${BASE}
if [ $? -eq 0 ]; then 
	# your local branch is now rebased; need to push those changes to your remote branch
	git push -f origin
fi
