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

## Still Not Working?

Try the simpler approach first:
1. Install [RSMods](https://github.com/Lovrom8/RSMods)
2. Enable "Direct Connect" mode
3. Select your USB cable as input in Rocksmith settings

Direct Connect works for most generic cables without needing RS_ASIO.
