# Usage: tests/install_test.ps1 <install-dir>  (set ODD_EVEN_BASE_URL to test unreleased builds)
param([Parameter(Mandatory)][string]$Dir)
# Not 'Stop': in Windows PowerShell 5.1 that turns odd-even's stderr (2>$null) into a terminating error.
$ErrorActionPreference = 'Continue'

$exe = Join-Path $Dir 'odd-even.exe'
$originalPath = [Environment]::GetEnvironmentVariable('Path', 'User')

function fail($msg) {
    [Console]::Error.WriteLine("FAIL: $msg")
    exit 1
}

try {
    $env:ODD_EVEN_INSTALL_DIR = $Dir
    Get-Content -Raw .\install.ps1 | Invoke-Expression
    if ($ErrorActionPreference -ne 'Continue') { fail "install.ps1 leaked ErrorActionPreference=$ErrorActionPreference into the caller" }

    if (-not (Test-Path $exe)) { fail "$exe not installed" }
    if ((& $exe 5) -ne '5 is odd') { fail 'odd-even 5' }
    if ((& $exe -4) -ne '-4 is even') { fail 'odd-even -4' }
    & $exe abc 2>$null; if ($LASTEXITCODE -ne 1) { fail "odd-even abc exited $LASTEXITCODE, want 1" }
    & $exe 2>$null; if ($LASTEXITCODE -ne 2) { fail "odd-even (no args) exited $LASTEXITCODE, want 2" }

    if (Get-Item $exe -Stream Zone.Identifier -ErrorAction SilentlyContinue) { fail 'Mark-of-the-Web is set' }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $Dir) { fail 'install dir not added to user PATH' }

    $saved = $env:ODD_EVEN_BASE_URL
    $env:ODD_EVEN_BASE_URL = ''
    $env:ODD_EVEN_VERSION = 'v0.0.0-nope'
    $env:ODD_EVEN_INSTALL_DIR = Join-Path $Dir 'bad'
    $failed = $false
    try { Get-Content -Raw .\install.ps1 | Invoke-Expression *> $null } catch { $failed = $true }
    if (-not $failed) { fail 'install of a nonexistent version succeeded' }
    $env:ODD_EVEN_BASE_URL = $saved

    Write-Host "PASS: $(& $exe 5) (PowerShell $($PSVersionTable.PSVersion))"
} finally {
    [Environment]::SetEnvironmentVariable('Path', $originalPath, 'User')
}
