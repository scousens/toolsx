# create a link from $PROFILE to this file
# ~/.config/powershell/Microsoft.PowerShell_profile.ps1

$colors = $host.privatedata
$colors.ErrorForegroundColor = 'Cyan'
set-alias -name ve -value ~/git/venv.py311/bin/activate.ps1
set-alias -name gst -value 'gst.ps1'
set-alias -name cdg -value 'cdg.ps1'
set-alias -name ll -value 'gci'
set-alias -name vm-hookup -value '~/git/scoloco/misctools/vm-cleaner/vm-connect.ps1'

# update path
if ($env:OS -eq "Windows_NT") {
	# Windows
	#$HOME = $env:USERPROFILE
	$SEP=';'
	$DELIM='\'
} else {
	#$HOME = $env:HOME
	# Linux/Mac
	$SEP=':'
	$DELIM='/'
}
"$($HOME)$($DELIM)tools","$($HOME)$($DELIM)bin" | ?{ $env:path -split ';' -notcontains $_ } | %{ $env:PATH = "$($env:PATH)$SEP$_" }
$env:MYGIT_DIR = "$($HOME)$($DELIM)git"

function From-UnixEpoc($epoc) {
    ([System.DateTimeOffset]::FromUnixTimeMilliSeconds($epoc)).DateTime
}

#function gve { param($ve); . "$($env:MYGIT_DIR)/venv.$ve/bin/Activate.ps1" }
