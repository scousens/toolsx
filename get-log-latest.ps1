# we create directories under logs for each test run/invocation of pytest. Get the latest
if ((split-path $PWD.path -leaf) -eq "logs") {
        $logsdir = '.'
} else {
        $logsdir = 'logs'
}
$d = Get-ChildItem (Join-Path $logsdir 'test_execution_2*') | select -last 1
Join-Path -Path $d.fullname -ChildPath "all-logs.log"
