#! /bin/zsh
inifile="$HOME/bin/testvms.ini"
test -e "$(dirname $0)/testvms.ini" && inifile="$(dirname $0)/testvms.ini"
source "$inifile"
vm=`echo "$1" | tr '[:lower:]' '[:upper:]'`
ip="${(P)vm}"
if [ "$vm" != "" ] && [ "$ip" != "" ]; then
  IP=$ip
  if [ "${vm:0:3}" = "NMC" ]; then
    APP='nmc'
  else
    APP='filer'
  fi
  echo "Doing $vm at $IP [$APP]"
else
  echo "fallback"
  if [ "$1" = "all" ]; then
    echo "all - TBD"
  elif [ "$1" = "nmc" ]; then
   IP=$NMC1
   APP='nmc'
  elif [ "$1" = "nea" ] || [ "$1" = "filer" ]; then
   IP=$NEA1
   APP='filer'
  else
   echo "Need to specify 'nmc' or 'nea'"
   exit 1
  fi
fi
shift
# debug
echo Whats left for params is: !$*!
if ! python --version; then
  echo
  echo ----- WHOOPS -------
  echo Not in venv - no python - FIX IT!
  echo
  exit 1
fi
set -x
pushd $MYGIT_DIR/gh/unity
python ../dev-tools/sync_dev.py $IP --$APP $*
popd
