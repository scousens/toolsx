#! /bin/bash 

##git status --porcelain | grep '^ M ' | awk '{print $2}' | xargs -I {} git add {}
# $ git status -sb --porcelain
# ## develop...origin/develop
# $ git status -sb --porcelain
# ## foo

echo
echo "The following branches have a deleted tracking branch - can be deleted"
# $ git branch -vv
#  develop            ccc7140 [origin/develop] Scr 3139 in take call (#390)
#* master             b219481d [origin/master] SA-900 pytest junit update - new node testsuites
#  onboard_script     6c0a027b [origin/onboard_script: gone] onboarding bootstrapping mac script
#                                                    ^^^^^^
### look at the 3rd column - then look for : gone - these can be deleted

# git branch -vv | grep -e ": gone]" | awk '{print $1 " -- " $3$4}'
# git branch -vv | awk -F'[^a-zA-Z0-9:/* -]' '{print $1 $2}' | grep ': gone'
#echo


long_and_convoluted() {
branches=$( git for-each-ref --format='%(refname:short) - %(upstream:short)' refs/heads/$1 )
# if the status is fatal, exit now
[[ "$?" -ne 0 ]] && exit 0

miabranches=()
while read -r line || [[ -n "$line" ]]; do
  #read -r b1 <<< $line 
  #echo "li=$line"
  b1=( $line )
  br="${b1[0]}"
  tr="${b1[2]}"
  #echo "br=$br"
  #echo "tr=$tr"
  if [[ ! -z $tr ]]; then
    trb=(${tr//\// })
    #for e in "${trb[@]}"; do
        #echo "trb=$e"
    #done
    #echo "r=${trb[0]}"
    #echo "b=${trb[1]}"
    #echo '-'
    #echo "CallGit: git ls-remote --heads --exit-code ${trb[0]} ${trb[1]})"
    git ls-remote --heads --exit-code ${trb[0]} ${trb[1]}  > /dev/null 2> /dev/null
    r=$?
    #echo "GitCall returns:$r"
    if [[ $r != 0 ]]; then
    	echo "MIA: $b1 -> $tr"
    	miabranches+=("${b1}")
	fi
  fi
done <<< "$branches"

}

branches=$(git branch -vv | grep -E '\[.+: gone\]')
if [[ $branches == "" ]]; then
  echo NONE
  exit
fi
echo "branches: [$branches]"
# if the status is fatal, exit now
[[ "$?" -ne 0 ]] && exit 0
for br in "${branches[@]}"; do
  echo $br
done

read -p "Nuke the MIA branches? " -n1 yn
if [ "$yn" == 'y' ] || [ "$yn" == 'Y' ]; then
	echo
	echo "Killing them..."
  miabranches=$(git branch -vv | grep -E '\[.+: gone\]' | awk '{ print $1 }')
	for br in ${miabranches[@]}; do
		read -p "Kill $br? " -n1 yn
    echo
		if [ "$yn" == 'y' ] || [ "$yn" == 'Y' ]; then
	      git branch -D $br
    	fi
	done
else
	echo "Done"
fi

echo "AllDone."
