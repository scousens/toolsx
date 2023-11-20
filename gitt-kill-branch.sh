#! /bin/bash

HT="Deletes a branch from local and remote (ORIGIN)
v2 [try to detect existance before deleting]

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
git branch | grep -q "${BRANCH}"
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

# validate origin is not scoutexchange
originrepo=` git remote get-url origin | awk -F':' ' {print $2}' | awk -F/ '{print $1}'`
if [ "${originrepo}" == "scoutexchange" ]; then
    echo "origin repo=${originrepo}"
    echo "Are you sure you want to delete this branch from SCOUTEXCHANGE repo?"
    read -p "Continue anyway?" yn
    if [ "${yn}" != "y" ]; then
        echo "Bailing out. (did not respond with 'y')"
        exit
    fi
fi

# move off the branch (if on it)
git branch | grep '*' | grep ${BRANCH} 
if [ $? -eq 0 ]; then 
  echo "Branch is current - checkout master/develop"
  git checkout master 2> /dev/null || git checkout develop
  if [ $? -gt 0 ]; then
      echo "Unable to checkout master - you may have stuff you need to stash!"
      exit 1
  fi
fi

branches_to_delete=`git branch -a | grep "[ /]${BRANCH}$"`
echo "to_delete: ${branches_to_delete}"

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

git branch -a | grep "[ /]${BRANCH}$" | grep remotes/origin
if [ $? -eq 0 ]; then
    echo "--delete branch ${BRANCH} on ORIGIN repo"
    git push origin --delete "${BRANCH}" 
    if [ $? -gt 0 ]; then
        errorcommand+="Error deleting remote branch in origin : ${BRANCH}"
        echo "-->Error deleting remote branch in ORIGIN : ${BRANCH}"
        echo "${errorcommand}"
        read -p "Continue?" yn
    fi
else
    echo "No branch found on origin remote"
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
git branch -a | grep "[ /]${BRANCH}$" && echo "Still have existing branches!!"
echo "ERRORS encountered:"
for i in "${errorcommand[@]}"; do
    echo "$i\n"
done
