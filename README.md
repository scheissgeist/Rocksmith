# Rocksmith 2014 - Generic USB Cable Guide

I spent two days trying to get a cheap USB guitar cable working with Rocksmith. This repo documents what actually worked.

## Before You Start

**Try the simple way first:** Rocksmith has a built-in "Microphone Mode" that works with generic USB cables. Go to Settings > Audio > Input and select your USB device. If that works, you don't need any of this.

If Microphone Mode doesn't work for you (it didn't for me — kept getting "cable not detected" errors), then this guide is your fallback.

## What This Does

Uses RS_ASIO + FL Studio ASIO to trick Rocksmith into accepting a generic USB guitar cable instead of the official $40 RealTone cable.

## Tested With

- TI PCM2902 USB CODEC cable (~$25 on Amazon)
- C-MEDIA USB Audio Device cable (~$20)
- Windows 11

## Quick Setup

Download the installer from [Releases](../../releases) and run it. It'll walk you through the setup.

Or do it manually — see [the detailed guide](docs/detailed-guide.md).

## How It Works

1. **RS_ASIO** hooks into Rocksmith and redirects audio to ASIO drivers
2. **FL Studio ASIO** wraps your regular Windows audio devices as ASIO
3. Registry settings tell FL Studio ASIO which devices to use
4. Rocksmith thinks it's talking to a proper audio interface

It's a bit of a hack, but it works.

## Common Issues

**Game crashes on startup:** Delete the `crd` files in your Steam userdata folder. Ubisoft sync causes problems.

**Guitar not detected:** Boost your USB mic input to 100% in Windows Sound settings.

**"Ubisoft servers unavailable" hang:** Block Rocksmith in Windows Firewall or spam ESC to skip.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more.

## Why Not Just Use Direct Connect / RSMods?

You probably should try that first. RSMods has a "Direct Connect" mode that's simpler than this whole setup:
- https://github.com/Lovrom8/RSMods

I made this guide because Direct Connect wasn't working for my particular cable, but it works for most people.

## Credits

- [RS_ASIO](https://github.com/mdias/rs_asio) by mdias — the actual magic
- [FL Studio ASIO](https://www.image-line.com/fl-studio-download/) — included with FL Studio, or install FL Studio demo to get it
- [RSMods](https://github.com/Lovrom8/RSMods) — try Direct Connect mode first

## License

MIT
