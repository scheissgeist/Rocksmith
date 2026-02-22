# Rocksmith 2014 Generic USB Cable Guide

[![Works on Windows 11](https://img.shields.io/badge/Windows%2011-Working-success)](https://github.com)
[![Rocksmith 2014](https://img.shields.io/badge/Rocksmith%202014-Remastered-blue)](https://store.steampowered.com/app/221680/Rocksmith_2014_Edition__Remastered/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Save $20+** by using generic USB guitar cables instead of the official RealTone cable

This guide helps you play **Rocksmith 2014** with **cheap generic USB guitar cables** (the $20-30 ones from Amazon/AliExpress) instead of the expensive official RealTone cable.

**Tested and working with:**
- ✅ TI PCM2902 USB CODEC cable
- ✅ C-MEDIA USB Audio Device cable  
- ✅ Windows 11 (build 26200)
- ✅ Rocksmith 2014 Remastered (Steam, latest version)

---

## 🎸 Quick Start (TL;DR)

### Option 1: Ultimate Installer (One-Click Setup) ⚡

**Download and run:** [ultimate-installer.bat](scripts/ultimate-installer.bat) or [ultimate-installer.ps1](scripts/ultimate-installer.ps1)

This will:
- ✅ Download FL Studio ASIO automatically
- ✅ Download RS_ASIO v0.7.4 automatically
- ✅ Find your audio devices
- ✅ Configure everything for you

### Option 2: Manual Setup

1. Install [FL Studio ASIO](https://www.image-line.com/fl-studio-asio/) (free)
2. Download [RS_ASIO v0.7.4](https://github.com/mdias/rs_asio/releases/tag/v0.7.4)
3. Follow the [detailed guide](docs/detailed-guide.md)

**Full guide:** See [docs/detailed-guide.md](docs/detailed-guide.md)

---

## 📋 What You Need

### Hardware
- Generic USB guitar cable (any brand)
- Electric guitar with 1/4" output
- Windows PC with audio output (speakers/headphones)

### Software
- **Rocksmith 2014 Remastered** (Steam)
- **[FL Studio ASIO](https://www.image-line.com/fl-studio-asio/)** - Free ASIO driver
- **[RS_ASIO v0.7.4](https://github.com/mdias/rs_asio/releases/tag/v0.7.4)** - Cable bypass mod

---

## 🚀 Setup Steps

### 1. Install FL Studio ASIO

FL Studio ASIO wraps Windows audio devices into ASIO format.

[Download here](https://www.image-line.com/fl-studio-asio/) → Run installer → Done

---

### 2. Find Your Audio Device GUIDs

Run [scripts/find-audio-guids.ps1](scripts/find-audio-guids.ps1) to discover your:
- **Output device** (speakers/headphones)
- **Input device** (USB guitar cable)

Or manually run this PowerShell command:

```powershell
# Output devices
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render" | ForEach-Object {
    $guid = $_.PSChildName
    $props = Get-ItemProperty "$($_.PSPath)\Properties" -ErrorAction SilentlyContinue
    $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
    if ($name) { Write-Host "$guid : $name" }
}

# Input devices
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture" | ForEach-Object {
    $guid = $_.PSChildName
    $props = Get-ItemProperty "$($_.PSPath)\Properties" -ErrorAction SilentlyContinue
    $name = $props."{b3f8fa53-0004-438e-9003-51a46e139bfc},6"
    if ($name) { Write-Host "$guid : $name" }
}
```

**Copy the GUIDs** — you'll need them in step 3.

---

### 3. Configure FL Studio ASIO

Replace `{OUTPUT_GUID}` and `{INPUT_GUID}` with your device GUIDs from step 2:

```powershell
$flAsioReg = "HKCU:\Software\Image-Line\ASIO"
if (-not (Test-Path $flAsioReg)) {
    New-Item -Path $flAsioReg -Force | Out-Null
}

Set-ItemProperty -Path $flAsioReg -Name "outputEndPoint" -Value "{OUTPUT_GUID}" -Type String
Set-ItemProperty -Path $flAsioReg -Name "inputEndPoint" -Value "{INPUT_GUID}" -Type String
Set-ItemProperty -Path $flAsioReg -Name "bufferSize" -Value 512 -Type DWord
```

---

### 4. Install RS_ASIO

1. Download [RS_ASIO v0.7.4](https://github.com/mdias/rs_asio/releases/tag/v0.7.4)
2. Extract the ZIP
3. Copy these 3 files to your Rocksmith folder:
   - `RS_ASIO.dll`
   - `RS_ASIO.ini`  
   - `avrt.dll`

**Rocksmith folder:** `C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014\`

---

### 5. Configure RS_ASIO

Edit `RS_ASIO.ini` in the Rocksmith folder:

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

**⚠️ IMPORTANT:** Save without BOM (Byte Order Mark). If using Notepad, save as "UTF-8" (not "UTF-8 with BOM").

---

### 6. Configure Rocksmith

Edit `Rocksmith.ini` in the Rocksmith folder:

```ini
[Audio]
RealToneCableOnly=0
ExclusiveMode=1
LatencyBuffer=4
Win32UltraLowLatencyMode=1
```

Keep other settings as-is. The key changes:
- `RealToneCableOnly=0` — allows generic cables
- `ExclusiveMode=1` — required for ASIO

---

### 7. Windows Audio Settings

#### A. Enable Exclusive Mode (Speakers)

1. Right-click **speaker icon** → **Sound settings**
2. **More sound settings** → **Playback** tab
3. Right-click your **speakers** → **Properties** → **Advanced** tab
4. ✅ Check "Allow applications to take exclusive control"
5. Click **OK**

#### B. Boost Guitar Input Level

1. **Recording** tab
2. Right-click your **USB guitar cable** (e.g., "USB Audio Device") → **Properties**
3. **Levels** tab → Set to **100%**
4. If available, set **Microphone Boost** to **+20dB**
5. Click **OK**

---

### 8. Launch Rocksmith

1. **Launch through Steam** (not by double-clicking the exe)
2. If "Ubisoft servers not available" appears, press **ESC** to skip
3. Go to **Settings → Calibration**
4. **Strum loudly** when prompted

**🎉 If calibration works, you're done!**

---

## 🐛 Troubleshooting

**Problem:** "No audio output device detected"  
**Fix:** [TROUBLESHOOTING.md#no-audio-output](TROUBLESHOOTING.md#no-audio-output)

**Problem:** Guitar not detected during calibration  
**Fix:** [TROUBLESHOOTING.md#guitar-not-detected](TROUBLESHOOTING.md#guitar-not-detected)

**Problem:** Game crashes or won't launch  
**Fix:** [TROUBLESHOOTING.md#game-crashes](TROUBLESHOOTING.md#game-crashes)

**See full troubleshooting guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🛠️ How It Works

- **RS_ASIO** intercepts Rocksmith's audio calls and redirects to ASIO drivers instead of looking for the RealTone cable
- **FL Studio ASIO** wraps Windows audio (WASAPI) into ASIO format, allowing any audio device to work as ASIO
- **Registry configuration** tells FL Studio ASIO which specific devices to use
- **Exclusive mode** gives ASIO full control of audio devices for low latency

---

## 📦 Alternative: ASIO4ALL

If FL Studio ASIO doesn't work, try **ASIO4ALL**:

1. Install [ASIO4ALL](https://www.asio4all.org/)
2. In `RS_ASIO.ini`, change `Driver=FL Studio ASIO` to `Driver=ASIO4ALL v2`
3. When Rocksmith launches, enable your devices in ASIO4ALL's control panel

**Note:** ASIO4ALL can be trickier — FL Studio ASIO is recommended.

---

## 📝 Tested Cables

| Cable | Chipset | Status |
|-------|---------|--------|
| Generic USB Audio CODEC | TI PCM2902 | ✅ Working |
| Generic USB Audio Device | C-MEDIA | ✅ Working |
| Behringer Guitar Link UCG102 | Unknown | ⚠️ Untested |
| Rocksmith Real Tone Cable | Official | ✅ Working (but expensive) |

**Have you tested another cable?** Please open a PR to add it!

---

## 🤝 Contributing

Contributions welcome! If you:
- Tested a different cable brand
- Found a solution to a new issue
- Improved the setup process

Please open a **Pull Request** or **Issue**.

---

## 📄 License

MIT License - See [LICENSE](LICENSE)

---

## 🙏 Credits

- **RS_ASIO** by [mdias](https://github.com/mdias/rs_asio)
- **FL Studio ASIO** by [Image-Line](https://www.image-line.com/fl-studio-asio/)
- Guide by Sean Wever (Feb 2026)

---

## ⭐ Support This Project

If this guide saved you money and helped you play Rocksmith:
- ⭐ **Star this repo**
- 🔀 **Share on Reddit** (r/rocksmith, r/pcgaming)
- 📹 **Make a YouTube tutorial** linking back here
- 💬 **Tell your friends**

---

**Questions?** Open an [issue](../../issues) or check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
