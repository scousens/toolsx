#! /bin/bash -x
# Args
# 1 - hostname/ip
# 2 - cifs sharename
# 3 - localdir
IP=$1
VOL=$2
DIR=$3
MNT="/Users/$USER/mnt/$3"
if ! test -d "$MNT" ; then
  echo "Mount dir [$3] does not exist in mnt"
  exit 1
fi 

# mac cifs public from file_util
#("mount", "-t", "smbfs", "-o", "-f=0777,-d=0777", "//guest:" + "@{hostname}/{share_name}", "{local_path}"),
mount -t smbfs -o "-f=0777,-d=0777" //guest:@$IP/$VOL $MNT

# mac cifs AD from file_util
#"mount", "-t", "smbfs", "-o", "-f=0777,-d=0777",f"//{username}:{password}" + "@{hostname}/{share_name}", "{local_path}",


#mount -t smbfs -o uid=$USER,password='' //$1/$2 $3
#mount -t smbfs //tester@<IP>/<share>   /Users/$USER/mnt/vol1

#mount -t smbfs -o nopassprompt //$IP/$VOL $MNT
#mount -t smbfs //$1/$2 $3
