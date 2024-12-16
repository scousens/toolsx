#! /bin/bash -x
# Args
# 1 - hostname/ip
# 2 - cifs sharename
# 3 - localdir
if ! test -d "$3" ; then
  echo "Mount dir [$3] does not exist"
  exit 1
fi 
#mount -t smbfs -o uid=$USER,password='' //$1/$2 $3
#mount -t smbfs //tester@<IP>/<share>   /Users/$USER/mnt/vol1

mount -t smbfs -N //$IP/$VOL /Users/$USERS/mnt/vol1
#mount -t smbfs //$1/$2 $3
