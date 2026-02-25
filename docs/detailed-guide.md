# Manual Setup Guide

Step-by-step instructions if you want to set this up yourself instead of using the installer.

## What You Need

1. Rocksmith 2014 Remastered (Steam)
2. A generic USB guitar cable (the $20 Amazon ones work)
3. FL Studio ASIO driver — comes with FL Studio, or just install the [FL Studio demo](https://www.image-line.com/fl-studio-download/) to get it
4. [RS_ASIO v0.7.4](https://github.com/mdias/rs_asio/releases/tag/v0.7.4)

## Step 1: Install FL Studio ASIO

Download FL Studio (even the free demo) from Image-Line. The ASIO driver gets installed with it.

https://www.image-line.com/fl-studio-download/

## Step 2: Find Your Device GUIDs

Windows assigns unique IDs to each audio device. You need to find these.

Open PowerShell and paste this:

```powershell
Write-Host "OUTPUT DEVICES:"
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render" | ForEach-Object {
    $guid = $_.PSChildName
    $props = Get-ItemProperty "$($_.PSPath)\Properties" -ErrorAction SilentlyContinue
    $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
    if ($name) { Write-Host "$guid : $name" }
}

Write-Host "`nINPUT DEVICES:"
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture" | ForEach-Object {
    $guid = $_.PSChildName
    $props = Get-ItemProperty "$($_.PSPath)\Properties" -ErrorAction SilentlyContinue
    $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
    if ($name) { Write-Host "$guid : $name" }
}
```

You'll see something like:
```
OUTPUT DEVICES:
{66837992-7897-4a54-8257-24e611050135} : Realtek(R) Audio

INPUT DEVICES:
{bc2e9a77-a2a1-4bd0-82fb-6879be4da0c4} : USB Audio Device
```

Write down the GUID for your speakers (output) and your USB cable (input).

## Step 3: Configure FL Studio ASIO

Tell FL Studio ASIO which devices to use. In PowerShell:

```powershell
$reg = "HKCU:\Software\Image-Line\ASIO"
if (-not (Test-Path $reg)) { New-Item -Path $reg -Force | Out-Null }

# Replace these with YOUR GUIDs from Step 2
Set-ItemProperty $reg -Name "outputEndPoint" -Value "{YOUR-OUTPUT-GUID-HERE}"
Set-ItemProperty $reg -Name "inputEndPoint" -Value "{YOUR-INPUT-GUID-HERE}"
Set-ItemProperty $reg -Name "bufferSize" -Value 512 -Type DWord
```

## Step 4: Install RS_ASIO

1. Download RS_ASIO v0.7.4 from GitHub: https://github.com/mdias/rs_asio/releases/tag/v0.7.4
2. Extract the zip
3. Copy these three files to your Rocksmith folder:
   - `RS_ASIO.dll`
   - `RS_ASIO.ini`
   - `avrt.dll`

Rocksmith folder is usually: `C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014\`

## Step 5: Edit RS_ASIO.ini

Open RS_ASIO.ini and replace its contents with:

```ini
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
```

**Important:** Save as UTF-8 without BOM. If using Notepad, check the encoding dropdown when saving.

## Step 6: Edit Rocksmith.ini

In the same folder, open Rocksmith.ini and make sure these are set:

```
RealToneCableOnly=0
ExclusiveMode=1
Win32UltraLowLatencyMode=1
```

## Step 7: Boost Input Volume

1. Right-click speaker icon in taskbar > Sound Settings
2. Click "More sound settings" or "Sound Control Panel"
3. Recording tab
4. Right-click your USB cable device > Properties
5. Levels tab > set to 100%

## Step 8: Block Ubisoft (Optional but Recommended)

Rocksmith hangs trying to connect to Ubisoft servers. Block it:

1. Windows key > type "Firewall" > open Windows Defender Firewall
2. Advanced Settings > Outbound Rules > New Rule
3. Program > Browse to Rocksmith2014.exe
4. Block the connection > name it "Rocksmith" > Finish

## Step 9: Launch and Test

1. Launch Rocksmith through Steam
2. If you see "Ubisoft servers unavailable", spam ESC
3. Go to calibration
4. Strum your guitar — it should detect

If calibration picks up your strums, you're done.

## It's Not Working

See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)

Or try the simpler approach: Install [RSMods](https://github.com/Lovrom8/RSMods) and use Direct Connect mode instead.
