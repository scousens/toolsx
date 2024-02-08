# create a link from $PROFILE to this file
# ~/.config/powershell/Microsoft.PowerShell_profile.ps1

$colors = $host.privatedata
$colors.ErrorForegroundColor = 'Cyan'
set-alias -name ve -value ~/git/venv.py39/bin/activate.ps1

function hookup {
  Connect-VIServer -Server vcenter-automation.ops.nasuni.net -User scousens@vsphere.local -Password bWTP4yhgc7aB2B-zCq2f
}
