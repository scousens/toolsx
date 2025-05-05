# tail 'all-logs' in latest test_execution directory
if ((split-path $PWD.path -leaf) -eq "logs") {
	$logsdir = '.'
} else {
	$logsdir = 'logs'
}
$last_log_dir = get-childitem (join-path $logsdir 'test_execution_*') | select -last 1
$logfile = Join-Path $last_log_dir.fullname "all-logs.log"
Write-Host -Fore green "Following $logfile"
Get-Content -Path $logfile -wait
