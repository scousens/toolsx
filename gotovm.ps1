param(
  [Parameter(Position = 0)]$t,
  [switch]$open,
  [switch]$auto,
  [switch]$help,
  [Parameter(ValueFromRemainingArguments = $true)]$rest
)
if ($help -or -not $t) {
  Write-Host "Usage: gotovm.ps1 [-open|-auto] KEY|IP [command...]"
  exit
}

$inifile = Join-Path $HOME "bin/testvms.ini"
$localIni = Join-Path $PSScriptRoot "testvms.ini"
if (Test-Path $localIni) { $inifile = $localIni }

# parse KEY='value' lines (shell-style ini)
$vms = @{}
if (Test-Path $inifile) {
  foreach ($line in Get-Content $inifile) {
    if ($line -match "^\s*([A-Za-z0-9_]+)\s*=\s*['""]?([^'""#\s]*)['""]?") {
      $vms[$matches[1].ToUpper()] = $matches[2]
    }
  }
}

$vm = $t.ToUpper()
$ip = $vms[$vm]
if ($ip) {
  $app = if ($vm.StartsWith("NMC")) { 'nmc' } else { 'filer' }
  Write-Host "Doing $vm at $ip [$app]"
} else {
  Write-Host "fallback"
  switch -Regex ($t.ToLower()) {
    '^nmc$'            { $ip = $vms['NMC1']; $app = 'nmc'; break }
    '^(nea|filer)$'    { $ip = $vms['NEA1']; $app = 'filer'; break }
    '^(nea|filer)([234])$' { $ip = $vms["NEA$($matches[2])"]; $app = 'filer'; break }
    '^rac$'            { $ip = $vms['RAC']; $app = 'filer'; break }
    default {
      # validate as a reachable ipv4 address (assume a nasuni appliance)
      if ($t -match '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' -and (Test-Connection -ComputerName $t -Count 1 -Quiet)) {
        $ip = $t
      }
    }
  }
  if (-not $ip) {
    Write-Host "Need to specify 'nmc' or 'nea'"
    exit 1
  }
}

if ($open) {
  Start-Process "http://$ip"
  exit
}

if ($auto) {
  $sshArgs = @("automation@$ip")
} else {
  $sshArgs = @("root@$ip", "-p222")
}
Write-Host "ssh $sshArgs $rest"
& ssh @sshArgs @rest
