#! /bin/bash

cmd='git status'
###; echo "----------------------------------";'
if [ -n "$1" ]; then 
    cmd=$*
    echo "Doing command '$cmd'"
fi

for item in `find . -name .git -type d | xargs dirname`; do 
    echo "Doing $item"
    pushd $item > /dev/null
    $cmd
    popd > /dev/null
done

