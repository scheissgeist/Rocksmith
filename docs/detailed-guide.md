# Rocksmith 2014 Generic USB Guitar Cable Setup Guide

**Successfully tested with:**
- TI PCM2902 USB CODEC cable
- C-MEDIA USB Audio Device cable
- Windows 11 (build 26200)
- Rocksmith 2014 Remastered (Steam)

This guide helps you use **generic USB guitar cables** (the cheap $20-30 ones) instead of the official $40+ RealTone cable.

---

## Prerequisites

1. **Rocksmith 2014 Remastered** installed via Steam
2. **Generic USB guitar cable** plugged in
3. **FL Studio ASIO** installed ([download here](https://www.image-line.com/fl-studio-asio/))
4. **RS_ASIO v0.7.4** ([download from GitHub](https://github.com/mdias/rs_asio/releases/tag/v0.7.4))

---

## Step 1: Install FL Studio ASIO

1. Download and install **FL Studio ASIO** (free driver that wraps Windows audio for ASIO)
2. During installation, make sure it registers the ASIO driver

---

## Step 2: Configure Windows Audio Settings

### A. Enable Exclusive Mode for Speakers

1. Right-click **speaker icon** in taskbar → **Sound settings**
2. Scroll down → **More sound settings** (or "Sound Control Panel")
3. Go to **Playback** tab
4. Right-click your **speakers** (e.g., "Realtek Speakers") → **Properties**
5. Go to **Advanced** tab
6. **Check** "Allow applications to take exclusive control of this device"
7. Click **OK**

### B. Boost Guitar Input Level

1. In the same Sound Control Panel, go to **Recording** tab
2. Right-click your **USB guitar cable** (e.g., "Microphone 3- USB Audio Device") → **Properties**
3. Go to **Levels** tab
4. Set slider to **100%**
5. If there's a **Microphone Boost** slider, set it to **+20dB** or maximum
6. Click **OK**

---

## Step 3: Get Device GUIDs

You need the Windows GUIDs for your audio devices.

Open **PowerShell** and run:

```powershell
# Find your speaker output GUID
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render" | ForEach-Object {
    $guid = $_.PSChildName
    $propsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\$guid\Properties"
    if (Test-Path $propsPath) {
        $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name) {
            Write-Host "$guid : $name"
        }
    }
}

Write-Host "`n--- INPUT DEVICES ---`n"

# Find your guitar cable input GUID
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture" | ForEach-Object {
    $guid = $_.PSChildName
    $propsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture\$guid\Properties"
    if (Test-Path $propsPath) {
        $props = Get-ItemProperty $propsPath -ErrorAction SilentlyContinue
        $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
        if ($name) {
            Write-Host "$guid : $name"
        }
    }
}
```

**Example output:**
```
{66837992-7897-4a54-8257-24e611050135} : Realtek(R) Audio

--- INPUT DEVICES ---

{bc2e9a77-a2a1-4bd0-82fb-6879be4da0c4} : USB Audio Device
```

**Copy the GUIDs** for:
- Your **speaker/headphone output** (e.g., Realtek Audio)
- Your **USB guitar cable input** (e.g., USB Audio Device or USB Audio CODEC)

---

## Step 4: Configure FL Studio ASIO

Open **PowerShell** and run (replace the GUIDs with yours from Step 3):

```powershell
$flAsioReg = "HKCU:\Software\Image-Line\ASIO"

# Create key if needed
if (-not (Test-Path $flAsioReg)) {
    New-Item -Path $flAsioReg -Force | Out-Null
}

# SET YOUR OUTPUT GUID HERE (speakers/headphones)
$outputGuid = "{66837992-7897-4a54-8257-24e611050135}"

# SET YOUR INPUT GUID HERE (USB guitar cable)
$inputGuid = "{bc2e9a77-a2a1-4bd0-82fb-6879be4da0c4}"

Set-ItemProperty -Path $flAsioReg -Name "outputEndPoint" -Value $outputGuid -Type String
Set-ItemProperty -Path $flAsioReg -Name "inputEndPoint" -Value $inputGuid -Type String
Set-ItemProperty -Path $flAsioReg -Name "bufferSize" -Value 512 -Type DWord

Write-Host "FL Studio ASIO configured successfully"
```

---

## Step 5: Install RS_ASIO

1. Download **RS_ASIO v0.7.4** from [GitHub releases](https://github.com/mdias/rs_asio/releases/tag/v0.7.4)
2. Extract the ZIP file
3. Copy these files to your Rocksmith folder:
   - `RS_ASIO.dll`
   - `RS_ASIO.ini`
   - `avrt.dll`

**Rocksmith folder location:**
```
C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014\
```

---

## Step 6: Configure RS_ASIO

Edit `RS_ASIO.ini` in the Rocksmith folder with this configuration:

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

**IMPORTANT:** Save the file without BOM (Byte Order Mark). If using Notepad, save as "UTF-8" not "UTF-8 with BOM".

---

## Step 7: Configure Rocksmith.ini

Edit `Rocksmith.ini` in the Rocksmith folder:

```ini
[Audio]
EnableMicrophone=0
ExclusiveMode=1
LatencyBuffer=4
ForceDefaultPlaybackDevice=
ForceWDM=0
ForceDirectXSink=0
DumpAudioLog=1
MaxOutputBufferSize=0
RealToneCableOnly=0
MonoToStereoChannel=0
Win32UltraLowLatencyMode=1

[Renderer.Win32]
ShowGamepadUI=0
ScreenWidth=0
ScreenHeight=0
Fullscreen=1
VisualQuality=1
RenderingWidth=0
RenderingHeight=0
EnablePostEffects=1
EnableShadows=1
EnableHighResScope=1
EnableDepthOfField=1
EnablePerPixelLighting=1
MsaaSamples=4
DisableBrowser=0

[Net]
UseProxy=1

[Global]
Version=1
```

**Key settings:**
- `RealToneCableOnly=0` — allows generic cables
- `ExclusiveMode=1` — required for ASIO
- `Win32UltraLowLatencyMode=1` — reduces latency

---

## Step 8: Fix Ubisoft Connection Issues

The game may hang trying to connect to Ubisoft servers. Two options:

### Option A: Block Rocksmith Internet Access (Recommended)

1. Press **Windows key** → type **"Windows Defender Firewall with Advanced Security"**
2. Click **Outbound Rules** on the left
3. Click **New Rule** on the right
4. Select **Program** → Next
5. Browse to: `C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014\Rocksmith2014.exe`
6. Select **Block the connection** → Next
7. Check all profiles (Domain, Private, Public) → Next
8. Name it **"Rocksmith"** → Finish

### Option B: Spam ESC to Skip Login

When the "Ubisoft servers are not available" message appears, repeatedly press **ESC** and **Enter** to skip it.

---

## Step 9: Launch and Test

1. **Launch Rocksmith 2014 through Steam** (not by double-clicking the exe)
2. Skip/close any Ubisoft login prompts
3. Plug in your guitar
4. Go to **Calibration** in the game menu
5. Strum your guitar loudly when prompted

**If calibration works:** You're done! 🎸

---

## Troubleshooting

### "No audio output device detected" Error

**Cause:** FL Studio ASIO can't access your output device.

**Fix:**
1. Make sure you enabled exclusive mode for your speakers (Step 2A)
2. Close any other audio applications (Discord, Spotify, etc.)
3. Verify the output GUID in FL Studio ASIO registry is correct

### Guitar Not Detected During Calibration

**Cause:** Input volume too low or wrong channel.

**Fix:**
1. Make sure microphone level is at 100% (Step 2B)
2. Turn your guitar's volume knob to maximum
3. Try changing `Channel=0` to `Channel=1` in `RS_ASIO.ini` under `[Asio.Input.0]`

### Game Crashes at "Loading Profile"

**Cause:** Ubisoft account sync issue.

**Fix:**
1. Go to: `C:\Program Files (x86)\Steam\userdata\[YOUR_ID]\221680\remote\`
2. Delete all `crd*` files
3. Right-click Rocksmith in Steam → Properties → Cloud Sync → **Disable**

### Audio is Choppy/Stuttering

**Cause:** Buffer size too small or xruns.

**Fix:**
1. In `RS_ASIO.ini`, increase `CustomBufferSize` from `512` to `1024` or `2048`
2. Also update FL Studio ASIO registry: `Set-ItemProperty -Path "HKCU:\Software\Image-Line\ASIO" -Name "bufferSize" -Value 1024`

### Game Won't Launch After Installing RS_ASIO

**Cause:** RS_ASIO compatibility issue with Windows 11.

**Fix:**
1. Verify all 3 RS_ASIO files are in the Rocksmith folder (`RS_ASIO.dll`, `RS_ASIO.ini`, `avrt.dll`)
2. Make sure `RS_ASIO.ini` has no BOM (re-save as UTF-8)
3. Try verifying game files in Steam: Right-click Rocksmith → Properties → Local Files → Verify Integrity

---

## Why This Works

- **RS_ASIO** intercepts Rocksmith's audio calls and redirects them to ASIO drivers instead of looking for the RealTone cable
- **FL Studio ASIO** wraps Windows audio (WASAPI) into ASIO format, allowing any Windows audio device to work as ASIO
- **Registry configuration** tells FL Studio ASIO which specific devices to use (your speakers and guitar cable)
- **Exclusive mode** lets RS_ASIO/FL Studio ASIO take full control of the audio devices for low latency

---

## Alternative: ASIO4ALL

If FL Studio ASIO doesn't work, you can try **ASIO4ALL** instead:

1. Download and install [ASIO4ALL](https://www.asio4all.org/)
2. In `RS_ASIO.ini`, change `Driver=FL Studio ASIO` to `Driver=ASIO4ALL v2` (both Output and Input sections)
3. When you launch Rocksmith, ASIO4ALL's control panel will appear
4. Enable your speakers (output) and USB guitar cable (input) by clicking the power button next to each device

**Note:** ASIO4ALL can be trickier to configure and may have "Not Connected" issues if devices aren't manually enabled.

---

## Credits

- **RS_ASIO** by mdias: https://github.com/mdias/rs_asio
- **FL Studio ASIO** by Image-Line: https://www.image-line.com/fl-studio-asio/
- Community troubleshooting and guide compilation (Feb 2026)

---

## Share This Guide

If this guide helped you, please share it with others struggling to get generic USB guitar cables working with Rocksmith!

Reddit communities:
- r/rocksmith
- r/pcgaming

Steam Guides:
- Upload as a Steam Community Guide for Rocksmith 2014

YouTube:
- Screen record the setup process as a tutorial

---

## Version History

**v1.0 (Feb 22, 2026)**
- Initial guide based on successful setup with TI PCM2902 and C-MEDIA cables on Windows 11

---

**Questions? Issues?** Check the RS_ASIO GitHub issues page: https://github.com/mdias/rs_asio/issues
