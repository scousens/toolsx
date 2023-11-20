#! /bin/bash
creset='\033[0m'
cprint1='\033[0;34m'  #blue
cprint2='\033[0;31m'  #red
cprint3='\033[0;35m'  #magenta

function get_choice_basic() {
    #prompt for a choice of 1ch options.
    # loop until a valid ans is provided. ESC to exit/abort
    # set $ans to answer
    args=$@
    local prompt="$1"
    local options="$2"
    ans=''
    echo "::ans=$ans; options=$options;"
    while [[ "${#ans}" == 0 || "$options" != *"$ans"* ]]; do
        read -n 1 -p "$prompt ($options) " ans
        if [ "$ans" == $'\e' ]; then
            echo 'ESC'
            exit 2
        fi
        echo $ans
    done
}

d=$1
if [ -z "$d" ]; then
	d='.'
fi
if [ ! -d "$d" ]; then
	exit
fi
cd $d
#d=`pwd`
d=$(pwd | sed -e 's!.*/git/!git/!')
echo -e "${cprint1}${d}${creset}"
##git status | grep "Your branch is"
git status -sb -uno --porcelain
branch=`git branch | awk '/\*/ { print $2 }'`
if git status | grep -q "Changes not staged for commit:"; then
    echo -e "${cprint2}OOOOPS${creset}. You have files checked out in ${cprint1}${d}${creset}; unable to synch"
    echo "Press <ENGER> to bail out"
    read -r response
    exit 1
fi
# first lets update our repo from origin
if (! git status --porcelain -sb -uno | grep -q "origin/"); then
    echo -e "${cprint2}WARNING: Branch ${branch} is local only. Nothing to sync.${creset}"
    exit 1
fi
git pull --prune

# now lets hitup upstream
upstream=`git remote | grep upstream`
if [ -z "$upstream" ]; then
    upstream="origin"
fi
echo -e "**Fetching ${cprint1}${d}${creset} from ${cprint2}${upstream}${creset} [${cprint3}${branch}${creset}]"
git fetch "$upstream" --prune
if [ "$?" == "1" ]; then
    echo "OOOOPS - in ${d};  <ENTER> to continue; <CTRL>-C to stop "
    read -r response
fi
# validate our branch is in upstream
if (! git branch -a | grep -q "${upstream}/${branch}"); then
    echo -e "${cprint2}WARNING: ${upstream}/${branch} does not exist -- bail out.${creset}"
    exit 1
fi
git status -sb -uno
# for non-forked repos - stop after the pull/fetch - no rebase
[[ "$upstream" == "origin" ]] && exit 0
get_choice_basic "M)erge R)ebase A)bort?" "mra"
[ "$ans" == "a" ] && exit
if [ "$ans" == "a" ]; then
	gitcmd='rebase'
else
	gitcmd='merge'
fi
echo -e "**Attempting a $gitcmd ${cprint1}${d}${creset}     ${cprint2}${upstream}${creset} / ${cprint3}${branch}${creset}"
echo "WARNING: if branches have diverged, do not proceed. need to figure out how to deal with rebase/merge/push."
echo "WARNING: ** Look at status output ** did our branches diverge?"
# get_choice_basic "Continue with rebase?" "yn"
# [ "$ans" == "n" ] && exit 
git $gitcmd "$upstream"/"$branch" 
if [ "$?" == "1" ]; then
    echo "OOOOPS - in ${d};  <ENTER> to continue"
    read -r response
    # TODO: abandon and redo as a merge?
fi
# if we are in fork, need to update origin[fork] with what we pulled from upstream[scout].
if [ "$upstream" != "origin" ]; then
    uprepo=` git remote get-url origin | awk -F':' ' {print $2}' | awk -F/ '{print $1}'`
    echo -e "Pulled ${cprint1}${d}${creset} from ${cprint2}${upstream}${creset} [${cprint3}${branch}${creset}]"
    tmp=`git status | grep "Your branch"`
    #regex compare
    if [[ "$tmp" =~ "is ahead of" ]]; then
        if [[ $d =~ /git/main ]]; then
            echo -e "${cprint2}WARNING${creset} we should never hit this in main! [CWD=$d] "
        fi
        echo -e "Pushing to ${cprint2}origin${creset} - repo:${cprint3}$uprepo${creset}"
		get_choice_basic "Push changes into origin? " "yn"
		if [[ "$ans" =~ ^[yY] ]]; then
    	    git push origin "$branch"
        fi
    elif [[ "$tmp" =~ "up-to-date" ]]; then
    	echo -e "${cprint3}**Origin is already up to date${creset}"
	else
		echo -e "UhOh. diverged branches? [status=${tmp}]"
        git status
        echo "OOOOPS - in ${d};  <ENTER> to continue"
        read -r response
    fi
    git fetch --prune
fi
