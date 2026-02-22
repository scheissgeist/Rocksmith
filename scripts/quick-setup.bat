@echo off
REM Rocksmith 2014 Generic USB Cable - Quick Setup Script
REM Run this AFTER installing FL Studio ASIO and RS_ASIO manually

echo ========================================
echo Rocksmith 2014 Generic Cable Setup
echo ========================================
echo.

REM Get audio device GUIDs
echo Step 1: Finding your audio devices...
echo.
echo OUTPUT DEVICES (Speakers/Headphones):
echo.
powershell -Command "$devices = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'; foreach ($d in $devices) { $guid = $d.PSChildName; $props = Get-ItemProperty \"$($d.PSPath)\Properties\" -ErrorAction SilentlyContinue; $name = $props.\"{b3f8fa53-0004-438e-9003-51a46e139bfc},6\"; if ($name) { Write-Host \"$guid : $name\" } }"

echo.
echo INPUT DEVICES (USB Guitar Cable):
echo.
powershell -Command "$devices = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture'; foreach ($d in $devices) { $guid = $d.PSChildName; $props = Get-ItemProperty \"$($d.PSPath)\Properties\" -ErrorAction SilentlyContinue; $name = $props.\"{b3f8fa53-0004-438e-9003-51a46e139bfc},6\"; if ($name) { Write-Host \"$guid : $name\" } }"

echo.
echo ========================================
echo.
echo Copy the GUID for your speakers/headphones (OUTPUT)
set /p OUTPUT_GUID="Paste OUTPUT GUID here: "

echo.
echo Copy the GUID for your USB guitar cable (INPUT)
set /p INPUT_GUID="Paste INPUT GUID here: "

echo.
echo Step 2: Configuring FL Studio ASIO...
powershell -Command "$flAsioReg = 'HKCU:\Software\Image-Line\ASIO'; if (-not (Test-Path $flAsioReg)) { New-Item -Path $flAsioReg -Force | Out-Null }; Set-ItemProperty -Path $flAsioReg -Name 'outputEndPoint' -Value '%OUTPUT_GUID%' -Type String; Set-ItemProperty -Path $flAsioReg -Name 'inputEndPoint' -Value '%INPUT_GUID%' -Type String; Set-ItemProperty -Path $flAsioReg -Name 'bufferSize' -Value 512 -Type DWord; Write-Host 'FL Studio ASIO configured'"

echo.
echo Step 3: Creating RS_ASIO.ini...
set RS_FOLDER=C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014

(
echo [Config]
echo EnableWasapiOutputs=0
echo EnableWasapiInputs=0
echo EnableAsio=1
echo.
echo [Asio]
echo BufferSizeMode=custom
echo CustomBufferSize=512
echo.
echo [Asio.Output]
echo Driver=FL Studio ASIO
echo BaseChannel=0
echo EnableSoftwareEndpointVolumeControl=1
echo EnableSoftwareMasterVolumeControl=1
echo SoftwareMasterVolumePercent=100
echo EnableRefCountHack=true
echo.
echo [Asio.Input.0]
echo Driver=FL Studio ASIO
echo Channel=0
echo EnableSoftwareEndpointVolumeControl=1
echo EnableSoftwareMasterVolumeControl=1
echo SoftwareMasterVolumePercent=100
echo EnableRefCountHack=true
echo.
echo [Asio.Input.1]
echo Driver=
echo Channel=1
echo.
echo [Asio.Input.Mic]
echo Driver=
echo Channel=
) > "%RS_FOLDER%\RS_ASIO.ini"

echo RS_ASIO.ini created

echo.
echo Step 4: Updating Rocksmith.ini...
powershell -Command "$rsFolder = 'C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014'; $iniPath = \"$rsFolder\Rocksmith.ini\"; $content = Get-Content $iniPath; $content = $content -replace 'RealToneCableOnly=.*', 'RealToneCableOnly=0'; $content = $content -replace 'ExclusiveMode=.*', 'ExclusiveMode=1'; $content = $content -replace 'Win32UltraLowLatencyMode=.*', 'Win32UltraLowLatencyMode=1'; Set-Content -Path $iniPath -Value $content"

echo Rocksmith.ini updated

echo.
echo ========================================
echo SETUP COMPLETE!
echo ========================================
echo.
echo Next steps:
echo 1. Make sure your guitar is plugged into the USB cable
echo 2. Launch Rocksmith 2014 through Steam
echo 3. Go to Settings ^> Calibration
echo 4. Strum your guitar when prompted
echo.
echo If you get "Ubisoft servers not available", press ESC to skip
echo.
pause
