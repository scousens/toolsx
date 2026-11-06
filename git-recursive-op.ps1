param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Command
)

if (-not $Command) {
    $Command = @('git', 'status')
}
Write-Host "Doing command '$($Command -join ' ')'"

$exe = $Command[0]
$cmdArgs = @($Command | Select-Object -Skip 1)

Get-ChildItem -Path . -Recurse -Directory -Force -Filter .git -ErrorAction SilentlyContinue |
    ForEach-Object {
        $item = $_.Parent.FullName
        Write-Host "Doing $item"
        Push-Location $item
        try {
            & $exe @cmdArgs
        }
        finally {
            Pop-Location
        }
    }
