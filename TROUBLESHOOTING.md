# Rocksmith 2014 Generic USB Cable - Troubleshooting Summary

## Problem
Trying to use generic USB guitar cables (TI PCM2902, C-MEDIA) with Rocksmith 2014 on Windows 11 instead of the official RealTone cable.

## Solution That Worked

**Configuration:**
- **Audio Driver:** FL Studio ASIO (wraps WASAPI to ASIO)
- **Cable Bypass:** RS_ASIO v0.7.4
- **OS:** Windows 11 build 26200
- **Buffer Size:** 512 samples
- **Input Channel:** 0 (mono)

## Key Steps

### 1. Install FL Studio ASIO
Free ASIO driver that wraps Windows audio devices: https://www.image-line.com/fl-studio-asio/

### 2. Configure FL Studio ASIO Registry
```powershell
$flAsioReg = "HKCU:\Software\Image-Line\ASIO"
Set-ItemProperty -Path $flAsioReg -Name "outputEndPoint" -Value "{OUTPUT_DEVICE_GUID}" -Type String
Set-ItemProperty -Path $flAsioReg -Name "inputEndPoint" -Value "{INPUT_DEVICE_GUID}" -Type String
Set-ItemProperty -Path $flAsioReg -Name "bufferSize" -Value 512 -Type DWord
```

Device GUIDs found at:
- Output: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\`
- Input: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture\`

### 3. Install RS_ASIO
Extract RS_ASIO v0.7.4 to Rocksmith folder:
- `RS_ASIO.dll`
- `RS_ASIO.ini`
- `avrt.dll`

### 4. Configure RS_ASIO.ini
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
```

**CRITICAL:** Save without BOM (Byte Order Mark) or RS_ASIO won't read it properly.

### 5. Configure Rocksmith.ini
```ini
RealToneCableOnly=0
ExclusiveMode=1
Win32UltraLowLatencyMode=1
```

### 6. Windows Audio Settings
- **Playback Device:** Enable "Allow applications to take exclusive control"
- **Recording Device (USB cable):** Set level to 100%, enable Microphone Boost if available

### 7. Fix Ubisoft Connection Hangs
Block Rocksmith internet access via Windows Firewall:
- Outbound rule blocking `Rocksmith2014.exe`
- Or spam ESC/Enter when "Ubisoft servers not available" appears

## Why It Works

1. **RS_ASIO** intercepts Rocksmith's audio initialization and redirects to ASIO drivers instead of looking for RealTone cable
2. **FL Studio ASIO** provides ASIO interface to any Windows audio device (WASAPI wrapper)
3. **Registry configuration** tells FL Studio ASIO exactly which devices to use
4. **Exclusive mode** allows ASIO to take full control for low latency
5. **Channel 0** maps to the mono guitar input (left channel)

## What Didn't Work

### ❌ ASIO4ALL
- Control panel was confusing ("Not Connected" states)
- Required manual device enabling during Rocksmith runtime
- FL Studio ASIO is more reliable and configurable via registry

### ❌ NoCableLauncher
- "Offsets not found" error on current Rocksmith version
- Outdated patcher incompatible with latest game build

### ❌ Direct WASAPI in RS_ASIO
- `EnableWasapiOutputs=1` and `EnableWasapiInputs=1` failed
- FL Studio ASIO wrapper was necessary

## Errors Encountered & Fixed

### Error: "No audio output device detected"
**Cause:** FL Studio ASIO couldn't access output device  
**Fix:** Enable exclusive mode for speakers in Windows Sound settings

### Error: "Your audio output device is not configured for Audio Exclusivity"
**Cause:** Exclusive mode disabled in Windows  
**Fix:** Sound settings → Playback → Speakers → Properties → Advanced → Check "Allow applications to take exclusive control"

### Error: Guitar not detected during calibration
**Cause:** Input volume too low (17%)  
**Fix:** Sound settings → Recording → USB Audio Device → Properties → Levels → Set to 100%

### Error: RS_ASIO not loading (no log file)
**Cause:** Launch method or file permissions  
**Fix:** Launch Rocksmith through Steam (not by double-clicking exe)

### Error: "0 render devices, 0 capture devices" in RS_ASIO log
**Cause:** UTF-8 BOM in RS_ASIO.ini confusing the parser  
**Fix:** Re-save RS_ASIO.ini without BOM:
```powershell
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($iniPath, $config, $utf8NoBom)
```

### Error: Game crashes at "Loading Profile"
**Cause:** Ubisoft account sync conflict with Steam Cloud  
**Fix:** Delete `crd*` files in Steam userdata folder, disable Steam Cloud Sync

### Error: Game hangs at "Connecting to Ubisoft servers"
**Cause:** Timeout waiting for Ubisoft connection  
**Fix:** Block Rocksmith internet access via Windows Firewall or spam ESC to skip

## Final Working Configuration

**Hardware:**
- Generic USB guitar cable (C-MEDIA USB Audio Device)
- Realtek onboard audio for output
- Any electric guitar with 1/4" cable

**Software Stack:**
- Rocksmith 2014 Remastered (Steam, latest version)
- RS_ASIO v0.7.4
- FL Studio ASIO (latest)
- Windows 11 build 26200

**Audio Chain:**
```
Guitar → USB Cable → FL Studio ASIO (WASAPI wrapper) → RS_ASIO → Rocksmith → FL Studio ASIO → Realtek Audio → Speakers
```

**Latency:**
- Buffer: 512 samples @ 48kHz = ~10.67ms
- Acceptable for rhythm guitar
- Can reduce to 256 samples if system handles it

## Files Created

1. **ROCKSMITH_GENERIC_CABLE_GUIDE.md** - Complete setup guide for users
2. **ROCKSMITH_QUICK_SETUP.bat** - Automated setup script (requires manual FL Studio ASIO + RS_ASIO installation first)
3. **rocksmith_troubleshooting_summary.md** - This file (developer notes)

## Share Links

**Reddit:**
- r/rocksmith: "Generic USB Guitar Cable Setup Guide (FL Studio ASIO + RS_ASIO)"
- r/pcgaming: "How to use cheap $20 USB guitar cables with Rocksmith 2014"

**Steam Community:**
- Upload as Steam Guide for Rocksmith 2014

**YouTube Tutorial:**
- Screen record the setup process
- Show Windows Sound settings configuration
- Show device GUID discovery
- Show RS_ASIO.ini editing
- Show in-game calibration working

## Credits

- **RS_ASIO** by mdias: https://github.com/mdias/rs_asio
- **FL Studio ASIO** by Image-Line: https://www.image-line.com/fl-studio-asio/
- Troubleshooting session: Sean Wever + Claude Sonnet (Feb 21-22, 2026)

---

**Result:** ✅ Working perfectly with generic USB cable!
