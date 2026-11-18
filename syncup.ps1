param([string]$Dir = '.')

$esc = [char]27
$reset = "$esc[0m"; $blue = "$esc[34m"; $red = "$esc[31m"; $magenta = "$esc[35m"

if (-not (Test-Path -LiteralPath $Dir -PathType Container)) { exit }
Set-Location -LiteralPath $Dir

$d = (Get-Location).Path -replace '\\', '/'
$d = $d -replace '^.*/git/', 'git/'
Write-Host "$blue$d$reset"

git status -sb -uno --porcelain
$branch = (git branch --show-current).Trim()

if (git status | Select-String -Quiet 'Changes not staged for commit:') {
    Write-Host "${red}OOOOPS$reset. You have files checked out in $blue$d$reset; unable to synch"
    Read-Host 'Press <ENTER> to bail out' | Out-Null
    exit 1
}

# local-only branch (no origin tracking) - nothing to sync
if (-not ((git status -sb -uno --porcelain | Select-Object -First 1) -match 'origin/')) {
    Write-Host "${red}WARNING: Branch $branch is local only. Nothing to sync.$reset"
    exit 1
}

Write-Host "**Pulling $blue$d$reset from ${red}origin$reset [$magenta$branch$reset]"
git pull --prune
if ($LASTEXITCODE -ne 0) {
    Read-Host "OOOOPS - in $d;  <ENTER> to continue; <CTRL>-C to stop" | Out-Null
}

# validate our branch exists in origin
if (-not (git branch -r | Where-Object { $_.Trim() -eq "origin/$branch" })) {
    Write-Host "${red}WARNING: origin/$branch does not exist -- bail out.$reset"
    exit 1
}

# final state
git status -sb -uno
exit 0
