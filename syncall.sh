#! /bin/bash -x
#find . -name .git | xargs -o -n1 -I {} echo "{}/.." 
find . -name .git | xargs -o -n1 -I {} syncup.sh '{}/..' 
#find . -name .git | xargs -n1 -t -I % sh -c 'cd %/..; git pull upstream' 
