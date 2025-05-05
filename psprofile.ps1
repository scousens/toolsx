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
$env:PATH = "$($env:PATH):$($env:HOME)/tools:$($env:HOME)/bin"
$env:MYGIT_DIR = "$($env:HOME)/git"

function From-UnixEpoc($epoc) {
	([System.DateTimeOffset]::FromUnixTimeMilliSeconds($epoc)).DateTime
}
