#! /bin/zsh
if [ "$1" = "open" ]; then
  OP="open"
  shift
fi
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
  if [ "$1" = "nmc" ]; then
   IP=$NMC1
   APP='nmc'
  elif [ "$1" = "nea" ] || [ "$1" = "filer" ]; then
   IP=$NEA1
   APP='filer'
  elif [ "$1" = "nea3" ] || [ "$1" = "filer3" ]; then
   IP=$NEA3
   APP='filer'
  elif [ "$1" = "nea4" ] || [ "$1" = "filer4" ]; then
   IP=$NEA4
   APP='filer'
  elif [ "$1" = "nea2" ] || [ "$1" = "filer2" ]; then
   IP=$NEA2
   APP='filer'
  elif [ "$1" = "rac" ] || [ "$1" = "rac" ]; then
   IP=$RAC
   APP='filer'
  else
    # try to validate it as an ipv4 address that is reachable, then go to it (assuming its a nasuni appliance).
    regex3="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
    if [[ $1 =~ $regex3 ]]; then
      if ping -c1 -o $1  > /dev/null ; then
        IP=$1
      fi
    fi
    if [[ "$IP" == "" ]]; then
      echo "Need to specify 'nmc' or 'nea'"
      exit 1
    fi
  fi
fi
shift
if [ "$OP" = "open" ]; then
  ARG="http://$IP"
  shift
else
  OP="ssh" 
  ARG=("root@$IP" "-p222")
fi
set -x
$OP $ARG $*
