echo
echo what shell am I running?
echo '---- #1 -- $0'
echo "$0"
echo '---- #2 -- /proc/$$/exe'
readlink /proc/$$/exe
echo '---- #3 -- $SHELL'
echo "$SHELL"
echo '---- #4 -- pid info ps -p $$'
ps -p $$
echo '---------'
