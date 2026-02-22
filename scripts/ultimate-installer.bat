@echo off
REM ============================================================
REM Rocksmith 2014 Generic USB Cable - Ultimate Installer
REM This script downloads and configures everything automatically
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ========================================================
echo    Rocksmith 2014 Generic USB Cable Installer
echo ========================================================
echo.
echo This will:
echo   1. Download FL Studio ASIO
echo   2. Download RS_ASIO v0.7.4
echo   3. Find your audio devices
echo   4. Configure everything automatically
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running as Administrator
) else (
    echo [WARNING] Not running as Administrator
    echo Some features may require admin rights later
)

echo.
echo ========================================================
echo STEP 1: Downloading FL Studio ASIO...
echo ========================================================
echo.

set "FLASIO_URL=https://support.image-line.com/redirect/flstudioasio_installer"
set "FLASIO_INSTALLER=%TEMP%\FL_Studio_ASIO_Setup.exe"

echo Downloading from Image-Line...
powershell -Command "try { Invoke-WebRequest -Uri '%FLASIO_URL%' -OutFile '%FLASIO_INSTALLER%' -UserAgent 'Mozilla/5.0' -MaximumRedirection 5; Write-Host '[OK] Downloaded FL Studio ASIO installer' } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }"

if errorlevel 1 (
    echo [ERROR] Failed to download FL Studio ASIO
    echo Please download manually from: https://www.image-line.com/fl-studio-asio/
    pause
    exit /b 1
)

echo.
echo Installing FL Studio ASIO...
echo (This will open an installer window)
start /wait "" "%FLASIO_INSTALLER%"

if errorlevel 1 (
    echo [WARNING] FL Studio ASIO installer may have failed
    echo Please check if it installed correctly
)

echo [OK] FL Studio ASIO installation complete
timeout /t 2 >nul

echo.
echo ========================================================
echo STEP 2: Downloading RS_ASIO v0.7.4...
echo ========================================================
echo.

set "RSASIO_ZIP=%TEMP%\rs_asio_v0.7.4.zip"
set "RSASIO_EXTRACT=%TEMP%\rs_asio"

echo Fetching latest release from GitHub...
powershell -Command "$url='https://github.com/mdias/rs_asio/releases/download/v0.7.4/release-0.7.4.zip'; Invoke-WebRequest -Uri $url -OutFile '%RSASIO_ZIP%' -UserAgent 'Mozilla/5.0'; Write-Host '[OK] Downloaded RS_ASIO v0.7.4'"

if errorlevel 1 (
    echo [ERROR] Failed to download RS_ASIO
    echo Please download manually from: https://github.com/mdias/rs_asio/releases
    pause
    exit /b 1
)

echo Extracting RS_ASIO files...
powershell -Command "Expand-Archive -Path '%RSASIO_ZIP%' -DestinationPath '%RSASIO_EXTRACT%' -Force; Write-Host '[OK] Extracted RS_ASIO files'"

echo.
echo ========================================================
echo STEP 3: Finding your audio devices...
echo ========================================================
echo.

echo Scanning Windows audio devices...
powershell -Command "$renderDevices = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'; $captureDevices = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture'; Write-Host ''; Write-Host 'OUTPUT DEVICES (Speakers/Headphones):'; Write-Host '-------------------------------------'; foreach ($d in $renderDevices) { $guid = $d.PSChildName; $props = Get-ItemProperty \"$($d.PSPath)\Properties\" -ErrorAction SilentlyContinue; $name = $props.\"{b3f8fa53-0004-438e-9003-51a46e139bfc},6\"; if ($name) { Write-Host \"$guid : $name\" } }; Write-Host ''; Write-Host 'INPUT DEVICES (USB Guitar Cable):'; Write-Host '-------------------------------------'; foreach ($d in $captureDevices) { $guid = $d.PSChildName; $props = Get-ItemProperty \"$($d.PSPath)\Properties\" -ErrorAction SilentlyContinue; $name = $props.\"{b3f8fa53-0004-438e-9003-51a46e139bfc},6\"; if ($name -and ($name -match 'USB|Guitar|Audio Device|Audio CODEC|Microphone')) { Write-Host \"$guid : $name\" } }"

echo.
echo ========================================================
echo STEP 4: Device Selection
echo ========================================================
echo.
echo Look at the devices listed above.
echo.

set /p OUTPUT_GUID="Paste your OUTPUT device GUID (speakers/headphones): "
set /p INPUT_GUID="Paste your INPUT device GUID (USB guitar cable): "

echo.
echo Selected:
echo   Output: %OUTPUT_GUID%
echo   Input:  %INPUT_GUID%
echo.
echo Is this correct? (Y/N)
set /p CONFIRM="> "
if /i not "%CONFIRM%"=="Y" (
    echo Cancelled. Please run the installer again.
    pause
    exit /b 0
)

echo.
echo ========================================================
echo STEP 5: Locating Rocksmith installation...
echo ========================================================
echo.

set "RS_FOLDER=C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014"

if exist "%RS_FOLDER%\Rocksmith2014.exe" (
    echo [OK] Found Rocksmith at: %RS_FOLDER%
) else (
    echo [WARNING] Rocksmith not found at default location
    echo.
    set /p RS_FOLDER="Enter your Rocksmith folder path: "
    if not exist "!RS_FOLDER!\Rocksmith2014.exe" (
        echo [ERROR] Rocksmith2014.exe not found in that folder
        pause
        exit /b 1
    )
)

echo.
echo ========================================================
echo STEP 6: Configuring FL Studio ASIO...
echo ========================================================
echo.

powershell -Command "$flAsioReg = 'HKCU:\Software\Image-Line\ASIO'; if (-not (Test-Path $flAsioReg)) { New-Item -Path $flAsioReg -Force | Out-Null }; Set-ItemProperty -Path $flAsioReg -Name 'outputEndPoint' -Value '%OUTPUT_GUID%' -Type String; Set-ItemProperty -Path $flAsioReg -Name 'inputEndPoint' -Value '%INPUT_GUID%' -Type String; Set-ItemProperty -Path $flAsioReg -Name 'bufferSize' -Value 512 -Type DWord; Write-Host '[OK] FL Studio ASIO configured'"

echo.
echo ========================================================
echo STEP 7: Installing RS_ASIO files...
echo ========================================================
echo.

echo Copying RS_ASIO files to Rocksmith folder...
copy /Y "%RSASIO_EXTRACT%\RS_ASIO.dll" "%RS_FOLDER%\" >nul
copy /Y "%RSASIO_EXTRACT%\avrt.dll" "%RS_FOLDER%\" >nul

if errorlevel 1 (
    echo [ERROR] Failed to copy files to Rocksmith folder
    echo You may need to run this installer as Administrator
    pause
    exit /b 1
)

echo [OK] Copied RS_ASIO.dll
echo [OK] Copied avrt.dll

echo.
echo ========================================================
echo STEP 8: Creating RS_ASIO.ini...
echo ========================================================
echo.

powershell -Command "$config = @'^
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
'^@; $utf8NoBom = New-Object System.Text.UTF8Encoding($false); [System.IO.File]::WriteAllText('%RS_FOLDER%\RS_ASIO.ini', $config, $utf8NoBom); Write-Host '[OK] Created RS_ASIO.ini'"

echo.
echo ========================================================
echo STEP 9: Configuring Rocksmith.ini...
echo ========================================================
echo.

powershell -Command "$iniPath = '%RS_FOLDER%\Rocksmith.ini'; if (Test-Path $iniPath) { $content = Get-Content $iniPath -Raw; $content = $content -replace '(?m)^RealToneCableOnly=.*$', 'RealToneCableOnly=0'; $content = $content -replace '(?m)^ExclusiveMode=.*$', 'ExclusiveMode=1'; $content = $content -replace '(?m)^Win32UltraLowLatencyMode=.*$', 'Win32UltraLowLatencyMode=1'; [System.IO.File]::WriteAllText($iniPath, $content); Write-Host '[OK] Updated Rocksmith.ini' } else { Write-Host '[WARNING] Rocksmith.ini not found - will be created on first launch' }"

echo.
echo ========================================================
echo STEP 10: Windows Audio Settings Check
echo ========================================================
echo.

echo Opening Windows Sound settings...
echo.
echo IMPORTANT: You need to manually set these:
echo.
echo 1. PLAYBACK tab:
echo    - Right-click your speakers ^> Properties ^> Advanced
echo    - Check "Allow applications to take exclusive control"
echo.
echo 2. RECORDING tab:
echo    - Right-click your USB guitar cable ^> Properties ^> Levels
echo    - Set microphone level to 100%%
echo    - Enable Microphone Boost if available (set to +20dB)
echo.
echo Press any key to open Sound settings...
pause >nul

start mmsys.cpl

echo.
echo Have you configured the audio settings? (Y/N)
set /p AUDIO_CONFIRM="> "
if /i not "%AUDIO_CONFIRM%"=="Y" (
    echo [WARNING] Please configure audio settings before playing
)

echo.
echo ========================================================
echo STEP 11: Cleanup
echo ========================================================
echo.

echo Cleaning up temporary files...
del /Q "%FLASIO_INSTALLER%" >nul 2>&1
del /Q "%RSASIO_ZIP%" >nul 2>&1
rmdir /S /Q "%RSASIO_EXTRACT%" >nul 2>&1

echo [OK] Cleanup complete

echo.
echo ========================================================
echo       INSTALLATION COMPLETE!
echo ========================================================
echo.
echo Your Rocksmith is now configured to use generic USB cables!
echo.
echo NEXT STEPS:
echo   1. Plug in your USB guitar cable
echo   2. Launch Rocksmith 2014 through Steam
echo   3. Skip Ubisoft login (press ESC if it hangs)
echo   4. Go to Settings ^> Calibration
echo   5. Strum your guitar when prompted
echo.
echo TROUBLESHOOTING:
echo   - If no audio: Check exclusive mode is enabled
echo   - If guitar not detected: Check microphone level is 100%%
echo   - If game hangs: Spam ESC to skip Ubisoft login
echo.
echo Full guide: https://github.com/scheissgeist/Rocksmith
echo.
echo ========================================================
echo.
pause
