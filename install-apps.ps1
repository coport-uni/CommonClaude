# install-apps.ps1
# 관리자 권한으로 PowerShell에서 실행하세요
# 실행: powershell -ExecutionPolicy Bypass -File .\install-apps.ps1

# 재부팅 필요 여부 플래그
$script:RebootNeeded = $false

#region winget 설치 확인 및 설치
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget이 이미 설치되어 있습니다." -ForegroundColor Green
        return
    }

    Write-Host "winget이 없습니다. 설치를 시작합니다..." -ForegroundColor Yellow

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
            Write-Host "winget 설치 완료." -ForegroundColor Green
        } else {
            throw "winget 설치 후에도 명령을 찾을 수 없습니다. PowerShell을 재시작한 뒤 다시 실행해 주세요."
        }
    }
    catch {
        Write-Host "winget 자동 설치 실패: $_" -ForegroundColor Red
        Write-Host "Microsoft Store에서 '앱 설치 관리자(App Installer)'를 수동으로 설치한 후 다시 실행하세요." -ForegroundColor Red
        exit 1
    }
}
#endregion

#region 설치 헬퍼 (이미 설치된 경우 건너뛰기)
function Install-App {
    param(
        [string]$Id,
        [string]$Name,
        [bool]$MayRequireReboot = $false
    )

    Write-Host "`n[$Name] 확인 중..." -ForegroundColor Cyan

    $installed = winget list --id $Id -e --accept-source-agreements 2>$null | Select-String -SimpleMatch $Id
    if ($installed) {
        Write-Host "  -> 이미 설치되어 있어 건너뜁니다." -ForegroundColor Yellow
        return
    }

    Write-Host "  -> 설치를 시작합니다..." -ForegroundColor Green
    winget install --id $Id -e --silent --accept-source-agreements --accept-package-agreements
    $code = $LASTEXITCODE

    # winget 재부팅 관련 종료 코드 처리
    # 0x8A150109 (-1978335479) = 설치 후 재부팅 필요
    # 0x8A150108 (-1978335480) = 재부팅 후 설치 재개 필요
    if ($code -eq 0) {
        Write-Host "  -> [$Name] 설치 완료." -ForegroundColor Green
    }
    elseif ($code -eq -1978335479 -or $code -eq -1978335480 -or $code -eq 3010) {
        Write-Host "  -> [$Name] 설치 완료 (재부팅 필요)." -ForegroundColor Yellow
        $script:RebootNeeded = $true
    }
    else {
        Write-Host "  -> [$Name] 설치 중 문제가 발생했습니다 (종료 코드: $code)." -ForegroundColor Red
    }

    # Docker처럼 재부팅이 거의 항상 필요한 앱은 플래그 강제 설정
    if ($MayRequireReboot -and $code -eq 0) {
        $script:RebootNeeded = $true
    }
}
#endregion

# ===== 실행 =====
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

Write-Host "`n모든 설치 작업이 완료되었습니다." -ForegroundColor Green

#region 자동 재부팅
if ($script:RebootNeeded) {
    Write-Host "`n일부 프로그램(예: Docker Desktop)을 완전히 사용하려면 재부팅이 필요합니다." -ForegroundColor Yellow

    $timeout = 30  # 초
    Write-Host "$timeout초 후 자동으로 재부팅됩니다. 취소하려면 아무 키나 누르세요..." -ForegroundColor Yellow

    $cancelled = $false
    for ($i = $timeout; $i -gt 0; $i--) {
        Write-Host "`r재부팅까지 $i초... (취소: 키 입력)   " -NoNewline
        if ([Console]::KeyAvailable) {
            [Console]::ReadKey($true) | Out-Null
            $cancelled = $true
            break
        }
        Start-Sleep -Seconds 1
    }
    Write-Host ""

    if ($cancelled) {
        Write-Host "자동 재부팅이 취소되었습니다. 나중에 직접 재부팅해 주세요." -ForegroundColor Cyan
    } else {
        Write-Host "재부팅합니다..." -ForegroundColor Green
        Restart-Computer -Force
    }
}
else {
    Write-Host "`n재부팅이 필요하지 않습니다." -ForegroundColor Green
}
#endregion
