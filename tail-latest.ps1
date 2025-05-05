# tail 'all-logs' in latest test_execution directory
if ((split-path $PWD.path -leaf) -eq "logs") {
	$logsdir = $PWD
} else {
	$logsdir = Join-Path $PWD 'logs'
}
$last_log_dir = Get-ChildItem (Join-Path $logsdir 'test_execution_2*') | Select-Object -last 1
$logfile = Join-Path $last_log_dir.fullname "all-logs.log"
Write-Host -Fore green "Following $logfile"
Get-Content -Path $logfile -wait
