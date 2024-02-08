#! /bin/bash
# fetch logs from env-service - hardcoded way
d=.
test $1 && d=$1
echo "copying logs to $d"
for x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
  scp env.auto.nasuni.net:tmp-logs/api$x .
done
