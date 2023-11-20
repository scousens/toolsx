echo
echo what shell am I running?
echo '---- #1'
echo "$0"
echo '---- #2'
readlink /proc/$$/exe
echo '---- #3'
echo "$SHELL"
echo '---- #4'
ps -p $$
echo '---------'
