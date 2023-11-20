#! /bin/bash

HT="Create a new <branch> in workspace based off origin/<basebranch> and push new branch to origin
Assumes ORIGIN as remote
Assumes ORIGIN / basebranch is uptodate!!! (esp if in fork)

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


echo "---create branch in ORIGIN repo; create/checkout w/ tracking branch"
echo git push origin origin/"${BASE}":refs/heads/"${BRANCH}" && echo git checkout --track -b "${BRANCH}" origin/"${BRANCH}" 
git push origin origin/"${BASE}":refs/heads/"${BRANCH}" && git checkout --track -b "${BRANCH}" origin/"${BRANCH}" && git status | grep "Your branch"
if [ $? -gt 0 ]; then
	echo "OOOOPS"
	exit 1
fi

echo "---branch ${BRANCH} created from ${BASE} (in origin)."
