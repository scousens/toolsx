#! /bin/bash -x
git status --porcelain | grep '^ M ' | awk '{print $2}' | xargs -I {} git add {}
git status -s -uno

