#! /bin/bash

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
command -v pwsh >/dev/null && [ -f "${0%.*}.ps1" ] && exec pwsh -NoProfile -File "${0%.*}.ps1" "$@"

git status --porcelain | grep -e '^ M ' -e "^MM " | awk '{print $2}' | xargs -I {} git add {}
git status -s -uno
