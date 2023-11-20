#! /bin/bash

HT="Deletes a branch from local and remote (ORIGIN)

Usage: ${0} <branchname>
"

if [ "${1}" == "-h" ]; then
        echo "${HT}"
        exit 1
fi

if [ -z "${1}" ]; then
    echo "You must specify the name of a branch to delete"
    echo "${HT}"
    exit 1
fi
BRANCH="${1}"

delete_flag='-d'
if  [ "${2}" == "-f" ]; then
    delete_flag="-D"
fi

#validate branch:
delete_local_branch=1
git branch | grep "${BRANCH}"
if [ $? -gt 0 ]; then
        echo
        echo "Unable to validate base branch ${BRANCH} as existing in your workspace"
        read -p "Continue anyway?" yn
        delete_local_branch=0
fi
echo
echo "--Our matching branches"
git branch -a | grep ${BRANCH}
echo
echo "---Good to GO"
echo "---Remove Branch:${BRANCH} from workspace, ORIGIN, and ORIGIN remote tracking"

# move off the branch (if on it)
git checkout develop 2> /dev/null || git checkout master
if [ $? -gt 0 ]; then
    echo "Unable to checkout master - you may have stuff you need to stash!"
    exit 1
fi

# delete the local branch
errorcommand=()
echo
if [[ "$delete_local_branch" == "1" ]]; then
    echo "---delete branch ${BRANCH} [${delete_flag}]"
    git branch ${delete_flag} "${BRANCH}" 
    if [ $? -gt 0 ]; then
        errorcommand+="Error deleting branch : ${BRANCH}"
        echo "-->Error deleting local branch : ${BRANCH}"
        echo "${errorcommand}"
        read -p "Continue?" yn
    fi
else
    echo "---branch ${BRANCH} is not in local workspace - skipping"
fi
echo
echo "--delete branch ${BRANCH} on ORIGIN repo"
git push origin --delete "${BRANCH}" 
if [ $? -gt 0 ]; then
    errorcommand+="Error deleting remote branch in origin : ${BRANCH}"
    echo "-->Error deleting remote branch in ORIGIN : ${BRANCH}"
    echo "${errorcommand}"
    read -p "Continue?" yn
fi
git branch --remotes | grep "origin/${BRANCH}"
if [ $? -gt 0 ]; then
        echo "No tracking branch found..."
else
    echo "delete remote tracking branch ${BRANCH}"
    git branch --delete --remotes origin/"${BRANCH}"
    if [ $? -gt 0 ]; then
        errorcommand+="Error deleting remote tracking branch : origin/${BRANCH}"
        echo "-->Error deleting remote tracking branch in : origin/${BRANCH}"
        echo "${errorcommand}"
        read -p "Continue?" yn
    fi
fi

echo "--"
echo "ERRORS encountered:"
for i in "${errorcommand[@]}"; do
    echo "$i\n"
done
