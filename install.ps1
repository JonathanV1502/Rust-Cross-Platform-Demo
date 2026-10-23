# Runs in its own scope so `irm | iex` doesn't leave settings or variables in the caller's session.
& {
    $ErrorActionPreference = 'Stop'
    # Windows PowerShell 5.1 defaults to TLS 1.0, which GitHub rejects.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $Repo = 'JonathanV1502/Rust-Cross-Platform-Demo'
    $Releases = "https://github.com/$Repo/releases"
    $Version = if ($env:ODD_EVEN_VERSION) { $env:ODD_EVEN_VERSION } else { 'latest' }
    $InstallDir = if ($env:ODD_EVEN_INSTALL_DIR) { $env:ODD_EVEN_INSTALL_DIR } else { "$env:LOCALAPPDATA\Programs\odd-even" }
    if ($env:ODD_EVEN_BASE_URL) {
        $BaseUrl = $env:ODD_EVEN_BASE_URL
    } elseif ($Version -eq 'latest') {
        $BaseUrl = "$Releases/latest/download"
    } else {
        $BaseUrl = "$Releases/download/$Version"
    }

    # throw, not exit: under `irm | iex` exit would close the user's terminal.
    function err($msg) {
        throw "error: $msg"
    }

    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        { $_ -in 'AMD64', 'ARM64' } { $target = 'x86_64-pc-windows-msvc' }
        default { err "unsupported architecture $arch (supported: x86_64, ARM64). See $Releases" }
    }

    $url = "$BaseUrl/odd-even-$target.exe"

    $tmp = [IO.Path]::GetTempFileName()
    try {
        Write-Host "Downloading $url"
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $tmp
        } catch {
            err "download failed (does release '$Version' exist?)"
        }

        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
        $exe = Join-Path $InstallDir 'odd-even.exe'
        Move-Item -Force $tmp $exe
        Unblock-File $exe -ErrorAction SilentlyContinue
    } finally {
        Remove-Item -Force $tmp -ErrorAction SilentlyContinue
    }

    & $exe 0 | Out-Null
    if ($LASTEXITCODE -ne 0) { err 'installed binary failed to run' }
    Write-Host "Installed odd-even to $exe"

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $InstallDir) {
        [Environment]::SetEnvironmentVariable('Path', "$InstallDir;$userPath".TrimEnd(';'), 'User')
        $env:Path = "$InstallDir;$env:Path"
        Write-Host ''
        Write-Host "Added $InstallDir to your PATH. Open a new terminal to use odd-even."
    }
}
