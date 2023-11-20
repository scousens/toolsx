#! /bin/bash

HT="Find local branches without a remote (local only)

Usage: ${0} [-l | -r]
 -l - print local only branches
 -r - print remote+local only branches

"
outs=''
if [ "${1}" == "-h" ]; then
        echo "${HT}"
        exit 1
elif [ "${1}" == "-l" ]; then
     outs='local'
elif [ "${1}" == "-r" ]; then
     outs='remote'
fi

#BRANCH="${1}"

#all_branches=(`git branch -a | grep ${BRANCH}`)
#echo "all_branches: ${branches_to_delete}"

local_branches=(`git branch --list`)
echo "Have ${#local_branches[@]}"
for branch in "${local_branches[@]}"; do
  matching_branches=(`git branch -a | grep -e "[ /]${branch}$"`)
  if [ "${#matching_branches[@]}" -eq 1 ]; then
    if [ "${outs}" == "local" ] || [ "${outs}" == "" ]; then
      echo "Branch:$branch is local only"
    fi
  elif [ "${#matching_branches[@]}" -gt 1 ]; then
    if [ "${outs}" == "remote" ] || [ "${outs}" == "" ]; then
      echo "Branch:$branch has  remote branches - ${#matching_branches[@]} total"
    fi
  #else
  fi
done
exit

git branch -a | grep ${BRANCH} | grep remotes/origin`
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
    echo bugbug git branch --delete --remotes origin/"${BRANCH}"
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
