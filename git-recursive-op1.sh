#! /bin/bash

function dumpit
{
    if [ -d $1 ]; then
        cd $1
        d=$(pwd | sed -e 's!.*/git/!./!')
        b=$(git branch | grep ^* | awk '{print $2}')
        t=$(git log -n1 | grep Date: | awk '{print $4 "-" $3 "-" $6 " "$5 " " $7}')
        echo "[${b}]; $d  [$t]"
    fi
}
export -f dumpit

#find . -name .git | xargs -o -n1 -I {} echo {}
#find . -name .git | xargs -n1 -I {} bash -c 'dumpit "$@"' _ {}
if [[ -z "$1" ]]; then
	find . -name .git -execdir pwd \; | xargs -n1 -I {} bash -c 'echo {}; cd {}; git status; echo "----------------------------------"; '
else
	find . -name .git -execdir pwd \; | xargs -n1 -I {} $1 {}
fi
