# create a link from $PROFILE to this file
# ~/.config/powershell/Microsoft.PowerShell_profile.ps1

$colors = $host.privatedata
$colors.ErrorForegroundColor = 'Cyan'
set-alias -name ve -value ~/git/venv.py311/bin/activate.ps1
set-alias -name gst -value 'gst.ps1'
set-alias -name cdg -value 'cdg.ps1'

# update path
$env:PATH = "$($env:PATH):~/tools"
$env:MYGIT_DIR = "~/git"

function From-UnixEpoc($epoc) {
	([System.DateTimeOffset]::FromUnixTimeMilliSeconds($epoc)).DateTime
}
