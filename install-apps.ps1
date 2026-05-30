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

#region Install helper (skips if already installed)
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

# ===== Execution =====
Ensure-Winget

$apps = @(
    @{ Id = "Google.Chrome";              Name = "Google Chrome";       Reboot = $false },
    @{ Id = "Docker.DockerDesktop";       Name = "Docker Desktop";      Reboot = $true  },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code";  Reboot = $false },
    @{ Id = "Anthropic.Claude";           Name = "Claude Desktop";      Reboot = $false },
    @{ Id = "Microsoft.Office";           Name = "Microsoft Office";    Reboot = $false },
    @{ Id = "Autodesk.Fusion360";         Name = "Autodesk Fusion 360"; Reboot = $false },
    @{ Id = "Git.Git";                    Name = "Git";                 Reboot = $false },
    @{ Id = "GitHub.GitHubDesktop";       Name = "GitHub Desktop";      Reboot = $false },
    @{ Id = "GitHub.cli";                 Name = "GitHub CLI";          Reboot = $false }
)

foreach ($app in $apps) {
    Install-App -Id $app.Id -Name $app.Name -MayRequireReboot $app.Reboot
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
