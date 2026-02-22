# Rocksmith 2014 Generic USB Cable - Ultimate PowerShell Installer
# Run this in PowerShell (Run as Administrator recommended)

#Requires -Version 5.1

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   Rocksmith 2014 Generic USB Cable Installer" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will automatically:" -ForegroundColor Yellow
Write-Host "  1. Download FL Studio ASIO"
Write-Host "  2. Download RS_ASIO v0.7.4"
Write-Host "  3. Find your audio devices"
Write-Host "  4. Configure everything"
Write-Host ""
$continue = Read-Host "Continue? (Y/N)"
if ($continue -ne "Y" -and $continue -ne "y") {
    exit
}

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "[OK] Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Not running as Administrator - some steps may fail" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 1: Downloading FL Studio ASIO..."
Write-Host "========================================================"
Write-Host ""

$flAsioUrl = "https://support.image-line.com/redirect/flstudioasio_installer"
$flAsioInstaller = "$env:TEMP\FL_Studio_ASIO_Setup.exe"

try {
    Write-Host "Downloading from Image-Line..."
    Invoke-WebRequest -Uri $flAsioUrl -OutFile $flAsioInstaller -UserAgent "Mozilla/5.0" -MaximumRedirection 5
    Write-Host "[OK] Downloaded FL Studio ASIO installer" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download manually: https://www.image-line.com/fl-studio-asio/"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Installing FL Studio ASIO..."
Write-Host "(Installer window will open - follow the prompts)"
Start-Process -FilePath $flAsioInstaller -Wait

Write-Host "[OK] FL Studio ASIO installation complete" -ForegroundColor Green
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 2: Downloading RS_ASIO v0.7.4..."
Write-Host "========================================================"
Write-Host ""

$rsAsioUrl = "https://github.com/mdias/rs_asio/releases/download/v0.7.4/release-0.7.4.zip"
$rsAsioZip = "$env:TEMP\rs_asio_v0.7.4.zip"
$rsAsioExtract = "$env:TEMP\rs_asio"

try {
    Write-Host "Downloading from GitHub..."
    Invoke-WebRequest -Uri $rsAsioUrl -OutFile $rsAsioZip -UserAgent "Mozilla/5.0"
    Write-Host "[OK] Downloaded RS_ASIO v0.7.4" -ForegroundColor Green
    
    Write-Host "Extracting files..."
    Expand-Archive -Path $rsAsioZip -DestinationPath $rsAsioExtract -Force
    Write-Host "[OK] Extracted RS_ASIO files" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download manually: https://github.com/mdias/rs_asio/releases"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 3: Finding your audio devices..."
Write-Host "========================================================"
Write-Host ""

Write-Host "OUTPUT DEVICES (Speakers/Headphones):" -ForegroundColor Yellow
Write-Host "-------------------------------------"

$renderDevices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
foreach ($device in $renderDevices) {
    $guid = $device.PSChildName
    $propsPath = "$($device.PSPath)\Properties"
    if (Test-Path $propsPath) {
        $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name) {
            Write-Host "$guid : $name"
        }
    }
}

Write-Host ""
Write-Host "INPUT DEVICES (USB Guitar Cable):" -ForegroundColor Yellow
Write-Host "-------------------------------------"

$captureDevices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"
foreach ($device in $captureDevices) {
    $guid = $device.PSChildName
    $propsPath = "$($device.PSPath)\Properties"
    if (Test-Path $propsPath) {
        $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name -and ($name -match "USB|Guitar|Audio Device|Audio CODEC|Microphone")) {
            Write-Host "$guid : $name"
        }
    }
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 4: Device Selection"
Write-Host "========================================================"
Write-Host ""

$outputGuid = Read-Host "Paste your OUTPUT device GUID (speakers/headphones)"
$inputGuid = Read-Host "Paste your INPUT device GUID (USB guitar cable)"

Write-Host ""
Write-Host "Selected:" -ForegroundColor Yellow
Write-Host "  Output: $outputGuid"
Write-Host "  Input:  $inputGuid"
Write-Host ""
$confirm = Read-Host "Is this correct? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled. Please run installer again."
    exit 0
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 5: Locating Rocksmith installation..."
Write-Host "========================================================"
Write-Host ""

$rsFolder = "C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014"

if (Test-Path "$rsFolder\Rocksmith2014.exe") {
    Write-Host "[OK] Found Rocksmith at: $rsFolder" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Rocksmith not found at default location" -ForegroundColor Yellow
    $rsFolder = Read-Host "Enter your Rocksmith folder path"
    if (-not (Test-Path "$rsFolder\Rocksmith2014.exe")) {
        Write-Host "[ERROR] Rocksmith2014.exe not found" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 6: Configuring FL Studio ASIO..."
Write-Host "========================================================"
Write-Host ""

$flAsioReg = "HKCU:\Software\Image-Line\ASIO"
if (-not (Test-Path $flAsioReg)) {
    New-Item -Path $flAsioReg -Force | Out-Null
}

Set-ItemProperty -Path $flAsioReg -Name "outputEndPoint" -Value $outputGuid -Type String
Set-ItemProperty -Path $flAsioReg -Name "inputEndPoint" -Value $inputGuid -Type String
Set-ItemProperty -Path $flAsioReg -Name "bufferSize" -Value 512 -Type DWord

Write-Host "[OK] FL Studio ASIO configured" -ForegroundColor Green

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 7: Installing RS_ASIO files..."
Write-Host "========================================================"
Write-Host ""

try {
    Copy-Item "$rsAsioExtract\RS_ASIO.dll" "$rsFolder\" -Force
    Copy-Item "$rsAsioExtract\avrt.dll" "$rsFolder\" -Force
    Write-Host "[OK] Copied RS_ASIO.dll" -ForegroundColor Green
    Write-Host "[OK] Copied avrt.dll" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to copy files: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to run PowerShell as Administrator"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 8: Creating RS_ASIO.ini..."
Write-Host "========================================================"
Write-Host ""

$config = @"
[Config]
EnableWasapiOutputs=0
EnableWasapiInputs=0
EnableAsio=1

[Asio]
BufferSizeMode=custom
CustomBufferSize=512

[Asio.Output]
Driver=FL Studio ASIO
BaseChannel=0
EnableSoftwareEndpointVolumeControl=1
EnableSoftwareMasterVolumeControl=1
SoftwareMasterVolumePercent=100
EnableRefCountHack=true

[Asio.Input.0]
Driver=FL Studio ASIO
Channel=0
EnableSoftwareEndpointVolumeControl=1
EnableSoftwareMasterVolumeControl=1
SoftwareMasterVolumePercent=100
EnableRefCountHack=true

[Asio.Input.1]
Driver=
Channel=1

[Asio.Input.Mic]
Driver=
Channel=
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("$rsFolder\RS_ASIO.ini", $config, $utf8NoBom)

Write-Host "[OK] Created RS_ASIO.ini" -ForegroundColor Green

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 9: Configuring Rocksmith.ini..."
Write-Host "========================================================"
Write-Host ""

$iniPath = "$rsFolder\Rocksmith.ini"
if (Test-Path $iniPath) {
    $content = Get-Content $iniPath -Raw
    $content = $content -replace '(?m)^RealToneCableOnly=.*$', 'RealToneCableOnly=0'
    $content = $content -replace '(?m)^ExclusiveMode=.*$', 'ExclusiveMode=1'
    $content = $content -replace '(?m)^Win32UltraLowLatencyMode=.*$', 'Win32UltraLowLatencyMode=1'
    [System.IO.File]::WriteAllText($iniPath, $content)
    Write-Host "[OK] Updated Rocksmith.ini" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Rocksmith.ini not found - will be created on first launch" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 10: Windows Audio Settings"
Write-Host "========================================================"
Write-Host ""

Write-Host "Opening Windows Sound settings..." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: You need to manually set:" -ForegroundColor Red
Write-Host ""
Write-Host "1. PLAYBACK tab:"
Write-Host "   - Right-click your speakers > Properties > Advanced"
Write-Host "   - Check 'Allow applications to take exclusive control'"
Write-Host ""
Write-Host "2. RECORDING tab:"
Write-Host "   - Right-click your USB guitar cable > Properties > Levels"
Write-Host "   - Set microphone level to 100%"
Write-Host "   - Enable Microphone Boost if available (+20dB)"
Write-Host ""
Read-Host "Press Enter to open Sound settings"

Start-Process "mmsys.cpl"

Write-Host ""
$audioConfirm = Read-Host "Have you configured the audio settings? (Y/N)"
if ($audioConfirm -ne "Y" -and $audioConfirm -ne "y") {
    Write-Host "[WARNING] Please configure audio settings before playing" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================================"
Write-Host "STEP 11: Cleanup"
Write-Host "========================================================"
Write-Host ""

Remove-Item $flAsioInstaller -ErrorAction SilentlyContinue
Remove-Item $rsAsioZip -ErrorAction SilentlyContinue
Remove-Item $rsAsioExtract -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[OK] Cleanup complete" -ForegroundColor Green

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "       INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Rocksmith is now configured for generic USB cables!" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Plug in your USB guitar cable"
Write-Host "  2. Launch Rocksmith 2014 through Steam"
Write-Host "  3. Skip Ubisoft login (press ESC if it hangs)"
Write-Host "  4. Go to Settings > Calibration"
Write-Host "  5. Strum your guitar when prompted"
Write-Host ""
Write-Host "TROUBLESHOOTING:" -ForegroundColor Yellow
Write-Host "  - If no audio: Check exclusive mode is enabled"
Write-Host "  - If guitar not detected: Check microphone level is 100%"
Write-Host "  - If game hangs: Spam ESC to skip Ubisoft login"
Write-Host ""
Write-Host "Full guide: https://github.com/scheissgeist/Rocksmith" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
