#! /bin/bash -x
git status --porcelain | grep -e '^ M ' -e "^MM " | awk '{print $2}' | xargs -I {} git add {}
git status -s -uno
