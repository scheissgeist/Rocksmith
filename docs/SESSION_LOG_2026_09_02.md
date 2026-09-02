# Session Log — 2026-09-02

**Project:** rocksmith-generic-cable-guide
**Agent:** Claude (Opus 5)
**Duration context:** long session (~80 min), unresolved

Symptom Sean reported: guitar audio "screeching" in Rocksmith 2014. Session
ended with the crash fixed and the screech characterized but NOT fixed.

---

## Outcome summary

| Problem | Status |
|---|---|
| Game crashed on startup / after login | **FIXED** — `systemdetection.dll` disabled |
| FL Studio ASIO pointed at a nonexistent input device | **FIXED** — repointed to the real cable |
| Screeching / rumble audio | **NOT FIXED** — characterized, cause not isolated |
| Hang on "Connecting to Ubisoft" (white screen) | **NOT DIAGNOSED** — appeared at end of session |

---

## The crash — FIXED

### Evidence

Six minidumps in the game folder from this session, all `0xc0000005`
(access violation), all the same failure bucket. Analyzed with `cdb`
(`!analyze -v`) — see "Debugger setup" below.

Call stack, consistent across every dump:

```
Rocksmith2014!luaopen_VenueBindings
  -> systemdetection!GetHardwareInstance
    -> dxdiagn!CDxDiagClassObject::GetChildContainer
      -> dxdiagn!CDxDiagProvider::ExecMethod
        -> dxdiagn!GetBasicDisplayInfo
          -> dxdiagn!EnumDisplayDevices_GDI
            -> dxdiagn!DisplayInfo::DisplayInfo
              -> dxdiagn!LoadDxDiagString+0x87   <-- FAULT
```

Buckets observed:
- `..._c0000005_D3D12Core.dll!NDXGI::CUMDAdapter::_CUMDAdapter` (3 dumps)
- `..._c0000005_dxdiagn.dll!LoadDxDiagString` (3 dumps)
- `..._c0000005_Rocksmith2014.exe!Unknown` (2 dumps, symbols unresolved)

**The fault moved around INSIDE dxdiagn as the hardware config changed.**
That is the signature of the enumeration itself being fragile, not one bad
device. This is the single most useful observation of the session — it is
what finally redirected the work away from chasing individual devices.

### The fix

```
cd "C:\Program Files (x86)\Steam\steamapps\common\Rocksmith2014"
ren systemdetection.dll systemdetection.dll.disabled
```

Safe because `systemdetection.dll` appears in **neither** the normal nor the
delay-load import table of `Rocksmith2014.exe`. Verified by parsing the PE
import directories directly, with a positive control: the same parser
returned **18 normal imports** for the binary (a non-empty result proving it
can read the table at all), and `systemdetection` was absent from that list.
The game loads it dynamically via `LoadLibrary`, so the load fails and the
game **skips hardware detection** rather than failing to start.

Rocksmith only uses that DLL to auto-detect graphics settings on first run.
`Rocksmith.ini` already carried explicit values
(`ScreenWidth=2560`, `ScreenHeight=1440`, `Fullscreen=1`, `MsaaSamples=4`),
so nothing depends on the detection result.

**Result: game launched and reached the song list.** Confirmed by Sean.

Backup: `systemdetection.dll.backup` in the session scratchpad, plus the
renamed `.disabled` file in place. To undo: rename it back.

---

## The FL Studio ASIO input device — FIXED

`HKCU:\Software\Image-Line\ASIO\inputEndPoint` was
`{0e8ddf28-1db3-4b0d-888b-d8af2cd98d9e}`. A lookup of that GUID under
`MMDevices\Audio\Capture` and `Render` returned nothing.

**Positive control for that lookup (same script, same run):** the sibling
`outputEndPoint` GUID `{66837992-7897-4a54-8257-24e611050135}` **did**
resolve — to `[Render] Speakers (Realtek(R) Audio), STATE: ACTIVE`. The probe
demonstrably finds endpoints that exist, so the null on the input GUID is a
fact about the registry, not about a broken probe.

So: the input pointed at a device that is not present in any state (not
disabled, not unplugged — absent), while the output pointed at a live one.
Likely a cable that once enumerated on a different USB port.

### Identifying the right device

Two generic USB audio chips are present; neither is a real Real Tone Cable
(genuine ones are `VID_12BA`, typically `12BA:00FF`):

| Device | Chip | Capture GUID |
|---|---|---|
| `USB Audio Device` | C-Media CM108 (`0D8C:0014`) | `{4068c711-0ae3-4134-b1b9-415e600a761b}` |
| `USB Audio CODEC` | TI PCM2902 (`08BB:2902`) | `{986f245a-05d2-42f3-876a-7083229d04a4}` |

Recorded 5s from each via ffmpeg dshow while Sean strummed:

- **CM108 `USB Audio Device`: mean -25.0 dB, peak -11.9 dB** ← the guitar
- PCM2902 `USB Audio CODEC`: mean -74.9 dB, peak -62.0 dB (noise floor)

50 dB apart — and each device produced a file, so both probes ran; the
difference is signal, not a failed capture. Matches this repo's own
TROUBLESHOOTING.md note that `USB Audio Device` is typically the cable and
`USB Audio CODEC` is typically a mixer/interface.

Set `inputEndPoint` to `{4068c711-...}`.
Registry backup: `ILASIO_backup.reg` (via `reg export`).

RS_ASIO confirms the spoof works — `audiodump.txt` shows
`{ASIO IN 0}[p:00ff v:12ba]`, i.e. the game sees a Real Tone Cable.

---

## The screech — NOT FIXED, but characterized

### What it is NOT (each ruled out by measurement)

| Suspect | Evidence against |
|---|---|
| The cable / guitar signal | Idle capture direct from the cable: **RMS -88.8 dB**, no dominant peaks, no mains series. Silent. |
| Sample-rate mismatch | Both endpoints probed: accept **48000 only**, reject 44100 (`PaErrorCode -9997`). Matched. |
| Mono/stereo channel handling | WASAPI capture: L and R **bit-identical**, `corr = 1.0`. Windows duplicating mono correctly. |
| Windows "Listen to this device" loopback | Only enabled on an unplugged Bluetooth device (state=8). Not the cable. |
| Buffer underrun | Level dead constant across captures; no dropouts. Buffer left at 512. |
| Guitar feedback / pickups | Present at identical level with the guitar untouched. |
| **AC mains hum** | **See correction below.** |

Positive control for the "cable is silent" null: the **same ffmpeg dshow
command against the same device** produced -25.0 dB when the guitar was
strummed. The capture path works; the -88.8 dB idle reading is real silence,
not a dead recorder.

### The mains-hum call was WRONG — twice, and the second time is instructive

First capture pointed at 119.8 Hz (2x 60 Hz) with 240 Hz alongside, and I
reported it as ground-loop hum. **That capture was Stereo Mix**, which is a
loopback of everything the OS renders — so I was measuring *game music* and
calling it cable noise. The cable itself measured -88.8 dB (silent).

Second time, capturing the game output while the sound was actually
occurring, 119.78 Hz and 240.23 Hz (ratio 2.006) were genuinely the two
strongest components. Still not hum:

```
120 Hz magnitude over 14s:  mean 1.417  std 1.181  min 0.001  max 5.883
coefficient of variation: 0.833   -> VARYING, not steady
```

Real mains hum is rock-steady. A CoV of 0.83 is content, not interference.
**Landing on mains frequencies is not sufficient to call something hum** —
the temporal behavior has to match too.

### What IS established

1. **Focus-dependent.** The sound exists only while the Rocksmith window has
   focus. Measured: steady ~-44 dB for 14s, dropping to **-92.5 dB (silence)**
   the instant focus left. This matches `AK::ReleaseAudioSink WMFocusCallback`
   / `AK::RestoreAudioSink WMFocusCallback` in `audiodump.txt` — Rocksmith
   releases its exclusive audio stream when unfocused.

   **This invalidated two earlier captures** that read -92.7 dB and looked
   like "nothing is playing" — running ffmpeg in the foreground stole focus
   and silenced the very thing being measured. Capture must be launched in
   the background with Sean clicking back into the game.

2. **Broadband, weighted to 1.5–4 kHz** (41% of energy there), with content
   across 80 Hz–10 kHz. Not a pure tone.

3. **Generated inside the game's audio chain**, since the cable is silent and
   the sound follows the game's audio stream lifecycle.

### The untested hypothesis (next thing to try)

`RS_ASIO.ini` `[Asio.Input.0]` has:

```
EnableSoftwareEndpointVolumeControl=1
EnableSoftwareMasterVolumeControl=1
SoftwareMasterVolumePercent=100
```

Meanwhile `RS_ASIO-log.txt` shows the game driving the input endpoint down:

```
SetMasterVolumeLevelScalar fLevel: 0.17
SetMasterVolumeLevelScalar fLevel: 0.191165
```

The game sets the hardware input to 17%; RS_ASIO applies 100% software gain
on top. Software gain amplifies the noise floor along with signal, which fits
a broadband fluctuating artifact.

Setting both `Enable*VolumeControl` to `0` in the **input** section only
(NOT output — output gain is what makes the game audible) was applied, but
the Ubisoft hang interrupted before it could be evaluated. **Reverted** so
the next session tests one variable at a time.

Note: this repo's README says "set the mic level to 100%" — that refers to
the **Windows** level, not this RS_ASIO software multiplier stacked on top.

---

## The Ubisoft hang — NOT DIAGNOSED

Last event of the session: white screen frozen at "Connecting to Ubisoft".
Process was gone by the time it was inspected (Sean closed it).
**No crash dump produced** (newest remained the 11:30 one), and `RS_ASIO-log.txt`
ends mid-capture with no error. So it hung rather than crashed.

Both documented fixes from TROUBLESHOOTING.md were already in place:
- Outbound firewall block rule: **present, enabled, correct path, all
  protocols/addresses/profiles** (verified via `Get-NetFirewallRule`, which
  returned three Rocksmith rules — a non-empty result, so the query works)
- No `crd*` files in
  `C:\Program Files (x86)\Steam\userdata\19209262\221680\remote\` to delete.
  Control: that same directory listing **did** return three other files
  (two `_PRFLDB` profiles and `LocalProfiles.json`), so the directory was
  read successfully and the absence of `crd*` is real.

Untested hypothesis: `Rocksmith.ini` has `[Net] UseProxy=1`. With outbound
fully blocked, a proxy attempt may stall rather than fail fast. Not verified.

Note the game DID get past this screen earlier in the same configuration, so
the hang is not deterministic. Per this repo's guide: spam ESC.

---

## Debugger setup (worth keeping — this is what broke the crash open)

WinDbg was already installed as an MSIX package, which is why a
`Windows Kits` path search found nothing:

```
C:\Program Files\WindowsApps\Microsoft.WinDbg_1.2606.22001.0_x64__8wekyb3d8bbwe\x86\cdb.exe
```

Use the **x86** build — `Rocksmith2014.exe` is 32-bit (verified from the PE
optional header magic `0x10b`).

```powershell
$cdb='C:\Program Files\WindowsApps\Microsoft.WinDbg_1.2606.22001.0_x64__8wekyb3d8bbwe\x86\cdb.exe'
$env:_NT_SYMBOL_PATH='srv*C:\symbols*https://msdl.microsoft.com/download/symbols'
& $cdb -z '<path to .mdmp>' -c '.symfix; .reload; !analyze -v; q'
```

Crash dumps are written by the game into its own install folder as
`rocksmith2014_396721_crash_<timestamp>C0.mdmp`.

---

## Machine state at session end

**Changes still in effect:**
- `systemdetection.dll` → `systemdetection.dll.disabled` (the crash fix — keep)
- FL Studio ASIO `inputEndPoint` → `{4068c711-...}` (the real cable — keep)
- 9 ghost monitor entries removed via Device Manager, 13 → 4 (harmless cleanup;
  did NOT fix the crash — the stack was byte-identical before and after)
- **AMD Radeon integrated GPU disabled** — did NOT fix anything, should be
  **re-enabled**. Left disabled only because the session ended.

**Reverted to session-start state:**
- `Rocksmith.ini` — byte-identical to backup (verified by `diff`)
- `RS_ASIO.ini` — byte-identical to backup (verified by `diff`)

**Backups** (session scratchpad,
`C:\Users\seanw\AppData\Local\Temp\claude\e--ZELDAFPS\b0f939d6-c793-4f0d-8253-4d5f3d6e3552\scratchpad\`):
- `Rocksmith.ini.bak_before_exclusive`
- `RS_ASIO.ini.bak_before_buffer`
- `systemdetection.dll.backup`
- `ILASIO_backup.reg`
- `monitors_before.csv`

---

## Open threads

1. **The screech.** Next concrete action: set
   `EnableSoftwareEndpointVolumeControl=0` and
   `EnableSoftwareMasterVolumeControl=0` in `[Asio.Input.0]` **only**, launch,
   and capture with ffmpeg **in the background** while the game holds focus.
   If unchanged, try Rocksmith's own in-game input volume slider, which is a
   separate control from both of these.

2. **The Ubisoft hang.** Test `UseProxy=0` in `Rocksmith.ini` `[Net]`.

3. **Re-enable the AMD Radeon adapter** in Device Manager. Disabling it
   accomplished nothing.

4. **Mismatched `dxdiagn.dll` versions** — System32 is `10.0.26100.8875`,
   SysWOW64 is `10.0.26100.8972`, same timestamp. Both Authenticode-valid.
   A mismatched servicing state; may be worth `sfc /scannow` or a DISM repair
   given the crash lived in that DLL.

---

## Method notes (mistakes made, so they are not repeated)

- **Measure at the layer the defect lives in.** Stereo Mix captures *all*
  system audio; it cannot tell you anything about cable noise. Capturing the
  cable device directly settled in one measurement what three Stereo Mix
  captures had confused.
- **A foreground capture tool steals focus**, and this game's audio is
  focus-dependent. The measurement silenced the phenomenon and then reported
  silence as a finding.
- **Every null needs a positive control.** "The GUID resolves to nothing" and
  "the cable is silent" are only meaningful because the same probes returned
  a live endpoint and a -25 dB strum respectively, in the same runs.
- **`ExclusiveMode=0` broke RS_ASIO entirely** — it throws
  `"Tried to initialize audio without exclusivity. Did you set ExclusiveMode=1
  in Rocksmith.ini?"`. RS_ASIO **requires** exclusive mode. This was a wrong
  change made on unverified reasoning; it cost a launch cycle.
- **The AMD GPU was proposed as the crash cause without isolating it.**
  Disabling it moved the fault within dxdiagn rather than fixing it — which
  was itself the clue that the module, not the device, was the problem.
- **Frequency alone does not identify a source.** Something can sit exactly on
  the 60 Hz harmonic series and still not be hum. Check whether the level is
  steady over time.
