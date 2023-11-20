#! /bin/bash

if [[ "$1" =~ "-\\?" || "$1" =~ "-h" ]]; then
  echo "Dump branches on origin sorted by date"
  echo "Options: --merged - incliude only merged branches"
  echo "         --no-merged - include only un-merged branches"
  echo "         --branch    - use git branch method (implies merge opts"
  echo "         --refs      - use git for-each (default)"
  exit
fi

gitbranch() {
merged=$1
if [[ "$merged" == "--merged" || "$merged" == "--no-merged" ]]; then
    echo 'Doing $merged branches'
elif [[ -n "$merged" ]]; then 
    echo 'Unknown param'
    exit 1
fi 

#for branch in `git branch -r $merged | grep origin | grep -v HEAD`; do echo -e `git show --format="%ci %cn %an " $branch | head -n 1` \\t$branch; done | sort -r
for branch in `git branch -r $merged | grep origin | grep -v HEAD`; do echo -e `git show --format="%ci  %an " $branch | head -n 1` \\t$branch; done | sort -r
}

gitforeach() {
git for-each-ref --format='%(committerdate) %09 %(authorname) %09 %(refname)' --sort=committerdate | grep /remotes/
}

if [[ "$1" == "" || "$1" == "--refs" ]]; then
  gitforeach
else
  if [[ "$1" == "--branch" ]]; then
    shift
  fi
  gitbranch $*
fi
