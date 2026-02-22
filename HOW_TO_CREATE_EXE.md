# Creating the EXE Installer

Since we can't automatically convert BAT to EXE, here's how YOU can do it:

## Method 1: Using Online Converter (Easiest)

1. Go to: https://bat2exe.net/
2. Upload `scripts/ultimate-installer.bat`
3. Click "Convert"
4. Download `RocksmithCableInstaller.exe`
5. Upload to GitHub Releases

## Method 2: Using Bat To Exe Converter (Best Quality)

1. **Download:** https://www.f2ko.de/downloads/Bat_To_Exe_Converter.zip
2. **Extract** and run `Bat_To_Exe_Converter.exe`
3. **Settings:**
   - Input: `E:\rocksmith-generic-cable-guide\scripts\ultimate-installer.bat`
   - Output: `E:\rocksmith-generic-cable-guide\RocksmithCableInstaller.exe`
   - **Options to check:**
     - ✅ Request Administrator privileges
     - ✅ Show console window
   - **Optional:** Add a guitar icon
4. Click **"Compile"**
5. You now have `RocksmithCableInstaller.exe`!

## Method 3: Create GitHub Release

1. Go to: https://github.com/scheissgeist/Rocksmith/releases
2. Click "Create a new release"
3. **Tag:** v1.0
4. **Title:** "Rocksmith Generic Cable Installer v1.0"
5. **Description:**
   ```
   🎸 One-Click Installer for Generic USB Guitar Cables
   
   Download `RocksmithCableInstaller.exe` and run it - that's all!
   
   No technical knowledge required. Just follow the prompts.
   
   Works with ANY generic USB guitar cable.
   ```
6. **Upload** `RocksmithCableInstaller.exe`
7. Click **"Publish release"**

## After Creating Release

Update README.md line 7:

Change:
```markdown
**Download and run:** [RocksmithCableInstaller.exe](https://github.com/scheissgeist/Rocksmith/releases/latest) *(coming soon!)*
```

To:
```markdown
**[⬇️ DOWNLOAD INSTALLER](https://github.com/scheissgeist/Rocksmith/releases/latest/download/RocksmithCableInstaller.exe)**
```

Then commit and push:
```powershell
cd E:\rocksmith-generic-cable-guide
git add README.md
git commit -m "Add EXE installer download link"
git push
```

---

## For the GUI Installer

The GUI installer (`gui-installer.ps1`) is more complex and would require:

1. **ps2exe** to convert PowerShell to EXE
2. OR **Visual Studio** to compile as a proper Windows app

The BAT version is simpler and works great for now. The GUI can be a v2.0 feature!

---

## What Users Will Do:

1. Go to GitHub
2. Click "Download RocksmithCableInstaller.exe"
3. Run it
4. Click Next a few times
5. Done!

**Much simpler than downloading multiple files and running scripts!**
