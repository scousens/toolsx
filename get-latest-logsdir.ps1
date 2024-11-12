# we create directories under logs for each test run/invocation of pytest. Get the latest
if ((split-path $PWD.path -leaf) -eq "logs") {
        $logsdir = '.'
} else {
        $logsdir = 'logs'
}
Get-ChildItem (Join-Path $logsdir 'test_execution_2*') | select -last 1
