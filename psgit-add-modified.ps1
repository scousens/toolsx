# git add files that have been modified only
& git status --porcelain | select-string -pattern "^( M|MM) (\w.*)" | %{ & git add $_.matches.groups[2] }
#awk '{print $2}' | xargs -I {} git add {}
git status -s -uno
