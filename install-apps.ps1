# install-apps.ps1
# Run in PowerShell with administrator privileges
# Run command: powershell -ExecutionPolicy Bypass -File .\install-apps.ps1

# Flag indicating whether a reboot is required
$script:RebootNeeded = $false

#region Check for winget and install if missing
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is already installed." -ForegroundColor Green
        return
    }

    Write-Host "winget not found. Starting installation..." -ForegroundColor Yellow

    $temp = Join-Path $env:TEMP "winget-setup"
    New-Item -ItemType Directory -Force -Path $temp | Out-Null

    try {
        $vclibs = Join-Path $temp "VCLibs.appx"
        Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile $vclibs
        Add-AppxPackage -Path $vclibs -ErrorAction SilentlyContinue

        $xaml = Join-Path $temp "xaml.appx"
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" -OutFile $xaml
        Add-AppxPackage -Path $xaml -ErrorAction SilentlyContinue

        $bundle = Join-Path $temp "winget.msixbundle"
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $bundle
        Add-AppxPackage -Path $bundle

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "winget installation complete." -ForegroundColor Green
        } else {
            throw "winget command not found even after installation. Please restart PowerShell and run again."
        }
    }
    catch {
        Write-Host "Automatic winget installation failed: $_" -ForegroundColor Red
        Write-Host "Please install 'App Installer' manually from the Microsoft Store, then run again." -ForegroundColor Red
        exit 1
    }
}
#endregion

#region Check for Chocolatey and install if missing
function Ensure-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Chocolatey not found. Starting installation..." -ForegroundColor Yellow

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        # Refresh PATH so 'choco' is available in this session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "Chocolatey installation complete." -ForegroundColor Green
        } else {
            throw "choco command not found even after installation. Please restart PowerShell and run again."
        }
    }
    catch {
        Write-Host "Automatic Chocolatey installation failed: $_" -ForegroundColor Red
        Write-Host "See https://chocolatey.org/install for manual installation steps." -ForegroundColor Red
    }
}
#endregion

#region winget install helper (skips if already installed)
function Install-App {
    param(
        [string]$Id,
        [string]$Name,
        [bool]$MayRequireReboot = $false
    )

    Write-Host "`n[$Name] Checking..." -ForegroundColor Cyan

    $installed = winget list --id $Id -e --accept-source-agreements 2>$null | Select-String -SimpleMatch $Id
    if ($installed) {
        Write-Host "  -> Already installed, skipping." -ForegroundColor Yellow
        return
    }

    Write-Host "  -> Starting installation..." -ForegroundColor Green
    winget install --id $Id -e --silent --accept-source-agreements --accept-package-agreements
    $code = $LASTEXITCODE

    # Handle winget reboot-related exit codes
    # 0x8A150109 (-1978335479) = reboot required after install
    # 0x8A150108 (-1978335480) = reboot required to resume install
    if ($code -eq 0) {
        Write-Host "  -> [$Name] installation complete." -ForegroundColor Green
    }
    elseif ($code -eq -1978335479 -or $code -eq -1978335480 -or $code -eq 3010) {
        Write-Host "  -> [$Name] installation complete (reboot required)." -ForegroundColor Yellow
        $script:RebootNeeded = $true
    }
    else {
        Write-Host "  -> [$Name] a problem occurred during installation (exit code: $code)." -ForegroundColor Red
    }

    # Force the flag for apps like Docker that almost always require a reboot
    if ($MayRequireReboot -and $code -eq 0) {
        $script:RebootNeeded = $true
    }
}
#endregion

#region Chocolatey install helper (skips if already installed)
function Install-ChocoApp {
    param(
        [string]$Id,
        [string]$Name
    )

    Write-Host "`n[$Name] Checking (Chocolatey)..." -ForegroundColor Cyan

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "  -> Chocolatey is not available, skipping [$Name]." -ForegroundColor Red
        return
    }

    $installed = choco list --local-only --exact $Id --limit-output 2>$null | Select-String -SimpleMatch $Id
    if ($installed) {
        Write-Host "  -> Already installed, skipping." -ForegroundColor Yellow
        return
    }

    Write-Host "  -> Starting installation..." -ForegroundColor Green
    # Capture output so we can detect a checksum mismatch, while still showing it to the user
    $output = choco install $Id -y --no-progress 2>&1 | Tee-Object -Variable captured
    $output | Write-Host
    $code = $LASTEXITCODE
    $logText = ($captured | Out-String)

    # Detect a hash/checksum mismatch (common when the vendor updates the installer
    # but the package manifest's recorded checksum lags behind)
    $hashMismatch = $logText -match "(?i)hash(es)? (do(es)? not|don't) match" -or `
                    $logText -match "(?i)checksum.*(did not|does not|doesn't) match" -or `
                    $logText -match "(?i)checksums do not match"

    if (($code -ne 0 -and $code -ne 3010 -and $code -ne 1641) -and $hashMismatch) {
        Write-Host "  -> Checksum mismatch detected. Retrying with --ignore-checksums..." -ForegroundColor Yellow
        Write-Host "     (This bypasses integrity verification; only safe for trusted official packages.)" -ForegroundColor DarkYellow
        choco install $Id -y --no-progress --ignore-checksums
        $code = $LASTEXITCODE
    }

    # Chocolatey exit codes: 0 = success, 3010 = success but reboot required
    if ($code -eq 0) {
        Write-Host "  -> [$Name] installation complete." -ForegroundColor Green
    }
    elseif ($code -eq 3010 -or $code -eq 1641) {
        Write-Host "  -> [$Name] installation complete (reboot required)." -ForegroundColor Yellow
        $script:RebootNeeded = $true
    }
    else {
        Write-Host "  -> [$Name] a problem occurred during installation (exit code: $code)." -ForegroundColor Red
    }
}
#endregion

# ===== Execution =====
Ensure-Winget

# Apps installed via winget
$apps = @(
    @{ Id = "Google.Chrome";              Name = "Google Chrome";       Reboot = $false },
    @{ Id = "Docker.DockerDesktop";       Name = "Docker Desktop";      Reboot = $true  },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code";  Reboot = $false },
    @{ Id = "Anthropic.Claude";           Name = "Claude Desktop";      Reboot = $false },
    @{ Id = "Microsoft.Office";           Name = "Microsoft Office";    Reboot = $false },
    @{ Id = "Git.Git";                    Name = "Git";                 Reboot = $false },
    @{ Id = "GitHub.GitHubDesktop";       Name = "GitHub Desktop";      Reboot = $false },
    @{ Id = "GitHub.cli";                 Name = "GitHub CLI";          Reboot = $false }
)

foreach ($app in $apps) {
    Install-App -Id $app.Id -Name $app.Name -MayRequireReboot $app.Reboot
}

# Apps installed via Chocolatey (not reliably available in winget)
$chocoApps = @(
    @{ Id = "autodesk-fusion360"; Name = "Autodesk Fusion 360" }
)

if ($chocoApps.Count -gt 0) {
    Ensure-Chocolatey
    foreach ($app in $chocoApps) {
        Install-ChocoApp -Id $app.Id -Name $app.Name
    }
}

Write-Host "`nAll installation tasks complete." -ForegroundColor Green

#region Automatic reboot
if ($script:RebootNeeded) {
    Write-Host "`nSome programs (e.g. Docker Desktop) require a reboot to work fully." -ForegroundColor Yellow

    $timeout = 30  # seconds
    Write-Host "The system will reboot automatically in $timeout seconds. Press any key to cancel..." -ForegroundColor Yellow

    $cancelled = $false
    for ($i = $timeout; $i -gt 0; $i--) {
        Write-Host "`rRebooting in $i seconds... (press a key to cancel)   " -NoNewline
        if ([Console]::KeyAvailable) {
            [Console]::ReadKey($true) | Out-Null
            $cancelled = $true
            break
        }
        Start-Sleep -Seconds 1
    }
    Write-Host ""

    if ($cancelled) {
        Write-Host "Automatic reboot cancelled. Please reboot manually later." -ForegroundColor Cyan
    } else {
        Write-Host "Rebooting..." -ForegroundColor Green
        Restart-Computer -Force
    }
}
else {
    Write-Host "`nNo reboot required." -ForegroundColor Green
}
#endregion
