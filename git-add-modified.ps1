# git add files that have been modified only

git status --porcelain |
    Where-Object { $_ -match '^( M|MM) ' } |
    ForEach-Object { git add -- $_.Substring(3) }
git status -s -uno
#& git status --porcelain | select-string -pattern "^( M|MM) (\w.*)" | %{ & git add $_.matches.groups[2] }
