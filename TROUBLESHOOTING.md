# Troubleshooting

Real problems I ran into and how I fixed them.

## Game Won't Launch / Crashes Immediately

**The Ubisoft sync bug:** Rocksmith tries to sync with Ubisoft servers and crashes.

Fix:
1. Go to `C:\Program Files (x86)\Steam\userdata\YOUR_ID\221680\remote\`
2. Delete any files starting with `crd`
3. Block Rocksmith in Windows Firewall (outbound rule)

## Guitar Not Detected During Calibration

**Input volume is too low.** Windows defaults USB mics to like 17%.

Fix:
1. Right-click speaker icon > Sound Settings > More sound settings
2. Recording tab > right-click your USB cable > Properties
3. Levels tab > crank it to 100%
4. If there's a "Microphone Boost" option, enable it

## "No Audio Output Device Detected"

FL Studio ASIO can't grab your speakers because something else is using them.

Fix:
1. Close Discord, Spotify, Chrome, anything with audio
2. Make sure "Exclusive Mode" is enabled for your speakers (Playback > Properties > Advanced)

## RS_ASIO Not Loading (No Log File Created)

The RS_ASIO.ini file has a UTF-8 BOM (invisible bytes at the start) that breaks the parser.

Fix: Re-save the file. In Notepad, Save As > Encoding: UTF-8 (not "UTF-8 with BOM").

Or use PowerShell:
```powershell
$content = Get-Content "RS_ASIO.ini" -Raw
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText("RS_ASIO.ini", $content, $utf8)
```

## Game Hangs at "Connecting to Ubisoft"

Rocksmith is waiting for a server that will never respond.

Fix: Spam ESC repeatedly. Or block the game in Windows Firewall before launching.

## Audio is Choppy / Stuttering

Buffer size is too small for your system.

Fix: In RS_ASIO.ini, change `CustomBufferSize=512` to `CustomBufferSize=1024` or `2048`.

## "Channel 3 is beyond max ASIO channels"

You're trying to use a channel that doesn't exist on your device.

Fix: In RS_ASIO.ini under `[Asio.Input.0]`, make sure `Channel=0` (not 2 or 3).

## RS_ASIO.dll / RS_ASIO.ini Missing (Setup Needs to Re-run)

If RS_ASIO stops working after a reinstall, Windows update, or clean setup, the DLL and config files may be gone.

Symptoms:
- No `RS_ASIO.log` in your Rocksmith folder after launching the game
- Rocksmith says "Real Tone Cable" but guitar isn't detected

Fix: Re-run `scripts/auto-setup.ps1`. It will re-download RS_ASIO, drop the DLLs into your Rocksmith folder, recreate `RS_ASIO.ini`, and update `Rocksmith.ini`.

Note: If you have multiple USB audio devices (e.g. a Behringer mixer + a guitar cable), the script picks the first active USB device alphabetically. Verify it picked the right one — `USB Audio Device` is typically the generic cable, `USB Audio CODEC` is typically a mixer/interface.

## "CURRENT INPUT: Real Tone Cable" But Guitar Not Detected

This is actually correct behavior — RS_ASIO is working. Rocksmith displaying "Real Tone Cable" means the ASIO hook is active.

The issue is input signal level. Fix:
1. Right-click taskbar speaker → Sound settings → Recording tab
2. Find your USB Audio Device — check if the meter moves when you strum
3. If no movement: cable isn't sending signal (check physical connection)
4. If meter moves but Rocksmith doesn't detect: right-click → Properties → Levels → set to 100%

## Still Not Working?

Try the simpler approach first:
1. Install [RSMods](https://github.com/Lovrom8/RSMods)
2. Enable "Direct Connect" mode
3. Select your USB cable as input in Rocksmith settings

Direct Connect works for most generic cables without needing RS_ASIO.

## Game Crashes at Startup / After Login (0xc0000005) — dxdiagn

Symptom: game crashes to desktop, often at or just after the login /
"Connecting to Ubisoft" screen. Writes `rocksmith2014_396721_crash_*.mdmp`
into its own install folder. Deleting `crd*` files and the firewall rule do
NOT help, because this is not actually a network problem.

Cause: Rocksmith's `systemdetection.dll` calls DxDiag to enumerate your
hardware at startup, and `dxdiagn.dll` faults during that walk. Seen on a
dual-GPU machine (NVIDIA + AMD integrated), but the fault moves around inside
dxdiagn as hardware changes, so it is the enumeration that is fragile rather
than one specific device.

Fix — rename the DLL so the game skips hardware detection:

```
cd "C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014"
ren systemdetection.dll systemdetection.dll.disabled
```

This is safe: `systemdetection.dll` is not in the exe's import tables (the
game loads it dynamically), so the load simply fails and detection is
skipped. The game starts normally. Make sure `Rocksmith.ini` already has
explicit `ScreenWidth` / `ScreenHeight` / `Fullscreen` values, since nothing
will auto-detect them any more.

To confirm this is your crash before changing anything, analyze a dump. WinDbg
installs via `winget install Microsoft.WinDbg`; use the **x86** `cdb.exe`
because Rocksmith is 32-bit:

```powershell
$cdb='C:\Program Files\WindowsApps\Microsoft.WinDbg_1.2606.22001.0_x64__8wekyb3d8bbwe\x86\cdb.exe'
$env:_NT_SYMBOL_PATH='srv*C:\symbols*https://msdl.microsoft.com/download/symbols'
& $cdb -z '<path to .mdmp>' -c '.symfix; .reload; !analyze -v; q'
```

Look for `dxdiagn` and `systemdetection!GetHardwareInstance` in the stack.

## FL Studio ASIO Points at a Device That No Longer Exists

Symptom: loud screeching / garbage audio, or no guitar at all, even though
RS_ASIO loads fine and its log shows no errors.

Cause: FL Studio ASIO stores the chosen devices as raw GUIDs in
`HKCU:\Software\Image-Line\ASIO`. If you ever moved the cable to a different
USB port, the stored `inputEndPoint` can point at an endpoint that no longer
exists. RS_ASIO then reads buffers from nothing.

Check both stored GUIDs actually resolve:

```powershell
$k='HKCU:\Software\Image-Line\ASIO'
(Get-ItemProperty $k).inputEndPoint
(Get-ItemProperty $k).outputEndPoint
# then look each one up - a valid one appears under Capture or Render:
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture'
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
```

If one is missing from both, that is your bug. Find the right GUID with
`scripts/find-audio-guids.ps1` and set it:

```powershell
Set-ItemProperty -Path 'HKCU:\Software\Image-Line\ASIO' -Name 'inputEndPoint' -Value '{your-guid-here}'
```

To be sure which USB device is really the guitar (rather than guessing from
the name), record a few seconds from each while strumming and compare levels —
the cable will be tens of dB louder than the silent one:

```
ffmpeg -f dshow -i audio="Microphone (4- USB Audio Device)" -t 5 -y test.wav
ffmpeg -i test.wav -af volumedetect -f null -
```

## Do NOT Set ExclusiveMode=0

RS_ASIO **requires** `ExclusiveMode=1` in `Rocksmith.ini`. Setting it to 0
produces:

> Tried to initialize audio without exclusivity.
> Did you set ExclusiveMode=1 in Rocksmith.ini?

Exclusive mode is how RS_ASIO takes over the stream and hands it to the ASIO
driver. Leave it at 1.
