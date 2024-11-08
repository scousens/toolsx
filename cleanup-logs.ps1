# tail 'all-logs' in latest test_execution directory
if ((split-path $PWD.path -leaf) -eq "logs") {
	$logsdir = '.'
} else {
	$logsdir = 'logs'
}
$last_log_dirs = get-childitem (join-path $logsdir 'test_execution_*') | select -last 2
$reference_time = $last_log_dirs.LastWriteTime | sort-object | select -first 1
$cleanup_list = Get-ChildItem $logsdir | ?{ $_.LastWriteTime -lt $reference_time } 
$cleanup_list
$ans = Read-Host -Prompt "Delete? (y/N) " | ?{ $_ -and $_.Substring(0,1) -eq 'y'}
if ($ans) { 
  write-Host "nuke 'em" 
  Remove-Item -Recurse $cleanup_list
}
