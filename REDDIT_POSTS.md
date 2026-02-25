# Reddit Post (Updated)

Post this to r/rocksmith:

---

**Title:** Got a generic USB cable working - documenting what I tried

**Body:**

Spent two days getting a $25 Amazon USB guitar cable to work with Rocksmith. Posting what I learned in case it helps someone.

**TL;DR:** Try Microphone Mode or RSMods Direct Connect first. If those don't work, RS_ASIO + FL Studio ASIO is a fallback.

**What I tried:**

1. **Microphone Mode** (built into Rocksmith) - Didn't detect my cable
2. **RSMods Direct Connect** - Didn't know about this until someone mentioned it in my last post. Haven't tested yet but apparently works for most people
3. **NoCableLauncher** - "Offsets not found" error, seems outdated
4. **RS_ASIO + FL Studio ASIO** - This worked

**The setup that worked for me:**

- RS_ASIO hooks into Rocksmith and redirects audio to ASIO
- FL Studio ASIO wraps Windows audio as ASIO (registry config for device selection)
- Had to boost USB mic input to 100% in Windows or it wouldn't detect strums
- Had to block Rocksmith in firewall or it hangs on "Ubisoft servers unavailable"

I put together a guide with the config files and troubleshooting: https://github.com/scheissgeist/Rocksmith

**But honestly?** Try RSMods Direct Connect first. It's simpler and works for most generic cables. My solution is overkill if Direct Connect works for you.

---

## Notes

- Acknowledges Direct Connect exists (which I didn't know about before)
- Admits the solution might be overkill
- Doesn't oversell it
- No emojis or marketing speak
