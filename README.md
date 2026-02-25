# 🎸 Rocksmith 2014 - Use ANY Guitar Cable

## **No Technical Knowledge Needed!**

Save $20+ by using **any cheap USB guitar cable** instead of the expensive official RealTone cable.

### ⚡ Super Simple Setup (5 Minutes)

**[⬇️ DOWNLOAD INSTALLER](https://github.com/scheissgeist/Rocksmith/releases/download/v1.0/ultimate-installer.exe)** ← Click here!

Just download and run `ultimate-installer.exe` - it does everything for you.

**Or use the script version:** [ultimate-installer.bat](scripts/ultimate-installer.bat) or [ultimate-installer.ps1](scripts/ultimate-installer.ps1)

---

## How Simple Is This?

If you can:
- ✅ Download a file
- ✅ Click "Next" a few times  
- ✅ Adjust a volume slider

**Then you can do this!** No programming, no tech skills needed.

---

## What Works

- ✅ **ANY** generic USB guitar cable ($20-30 on Amazon)
- ✅ Windows 10 and Windows 11
- ✅ Rocksmith 2014 Remastered (Steam)
- ✅ Takes only 5 minutes

**Tested cables:**
- TI PCM2902 USB CODEC cable ✅
- C-MEDIA USB Audio Device cable ✅
- Your cable probably works too!

---

## 🚀 Quick Start

### Option 1: One-Click Installer (Easiest) ⚡

**[⬇️ DOWNLOAD INSTALLER](https://github.com/scheissgeist/Rocksmith/releases/download/v1.0/ultimate-installer.exe)**

Just run the EXE and click "Next" a few times!

**What it does:**
- Downloads everything you need
- Finds your devices automatically
- Sets everything up for you

**Just click "Next" a few times - that's it!**

### Option 2: Step-by-Step Manual Guide

Prefer to do it yourself? Follow the [detailed guide](docs/detailed-guide.md)

---

## 🐛 Having Trouble?

- **Check:** [Troubleshooting Guide](TROUBLESHOOTING.md)
- **Still stuck?** [Open an issue](../../issues) and we'll help!

---

## 📝 What You Need

- Any cheap USB guitar cable (works with almost all of them)
- Electric guitar
- Windows PC with Rocksmith 2014
- 5 minutes of your time

That's it!

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
- Community troubleshooting and guide compilation (Feb 2026)

---

**Questions?** Open an [issue](../../issues) or check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
