#! /bin/bash
# this is an update to git-kill-branch.sh 

HT="Deletes all found instances of the given branch

Usage: $(basename ${0}) <branchname> [--dry-run | --no-dry-run] [-h]
"

DRY=
BRANCH=
# parse the options
while [ "$1" != "" ]; do
    case $1 in
        --dry-run )
            DRY=echo
            ;;
        --no-dry-run )
            DRY=
            ;;
        -h | --help | -\? )
            echo "${HT}"
            exit
            ;;
        * )
            BRANCH="${1}"
            ;;
    esac
    shift
done

# validate BRANCH
if [ "${BRANCH}" == "develop" ] || [ "${BRANCH}" == "master" ]; then
        echo "Blocking delete of this branch ($1). Its special!!!"
        exit 1
fi
if [ -z "${BRANCH}" ]; then
    echo "You must specify the name of a branch to delete"
    echo "${HT}"
    exit 1
fi

# make sure not deleting the current branch
current_branch=`git status | head -n 1 | awk '{ print $3 }'`
if [[ "$current_branch" == "${BRANCH}" ]]; then
    echo "ERROR: cannot delete current branch. Checkout a different branch first."
    exit 1
fi

# given refspec origin/humpty set head=origin tail=humpty
# set variable head, tail to return actual manipulations
function splitref() {
    ref="$1"
    head="${ref%%/*}"
    tail="${ref#*/}"
}

# get the list of branches [Q: parameterize --all]
branch_list=(`git branch --list --all --no-color "*${BRANCH}" | grep "\W${BRANCH}"`)
# this appears to return a list of files also if BRANCH is develop
if [[ "${#branch_list[@]}" -eq 0 ]]; then
    echo "No branches found with the name : $BRANCH"
    exit 
fi
echo "Found ${#branch_list[@]} branches to DELETE"
for branch in "${branch_list[@]}"; do
    echo "  $branch"
done
#git branch -a | grep ${BRANCH}
# double check our earlier git call results - I saw it return all files in cwd for some input
branch_list2=(`git branch --list --all --no-color | grep $BRANCH`)
if [[ ${#branch_list[@]} != ${#branch_list2[@]} ]]; then
    echo -------
    echo "Um... our git command of choice appears to have fetched too much!! --FATAL"
    echo "The alternative:"
    for branch in "${branch_list2[@]}"; do
        echo "  $branch"
    done
    echo -------
    exit 1
fi
read -p "Nuke the MIA branches? " -n1 yn
if [ "$yn" == 'y' ] || [ "$yn" == 'Y' ]; then
    echo
else
    echo
    exit
fi
echo -n ... in 3 
for x in 1 2 3; do
    echo -n .
    sleep 1
done
echo
for branch in "${branch_list[@]}"; do
    if [[ "$branch" =~ ^remotes/ ]]; then
        # remove remotes/
        splitref $branch
        branch=$tail

        # split off remote name (origin) from branch ()
        splitref $branch
        remote=$head
        branch=$tail
        if [[ ! "$remote" =~ ^origin$ ]]; then
            echo "Bypassing non-origin branch [$remote / $branch] for now...."
            continue
        fi
        echo "Nuking remote branch [$branch on $remote] [git push --delete $remote $branch]"
        $DRY git push --delete $remote $branch
        if [ $? -gt 0 ]; then
            echo "Delete branch $remote $branch failed [$?]. --abort"
            exit 1
        fi
        # remote tracking branch
        git branch --remotes | grep "${BRANCH}"
        if [ $? -gt 0 ]; then
            echo "No tracking branch found..."
        else
            echo "delete remote tracking branch ${BRANCH} [git branch --delete --remotes $branch]"
            $DRY git branch --delete --remotes $branch
        fi
    else
        echo "Nuking local branch [$branch] [git branch --delete --force $branch]"
        $DRY git branch --delete --force $branch
    fi
    if [ $? -gt 0 ]; then
        echo "Delete branch $branch failed [$?]. --abort"
        exit 1
    fi
done
