# RainyDM media tools

Pinned **LGPL** builds of [FFmpeg](https://ffmpeg.org) that the RainyDM download manager fetches the
first time it needs to join audio and video or convert to MP3/M4A. RainyDM checks every file
against a SHA-256 pinned in its source (`MediaToolManifest`) and never runs anything that does not
match. This repository holds only these builds, the workflows that make them, and the license
texts; it contains no RainyDM code.

## Releases

Each release is tagged `ffmpeg-<version>` (for example `ffmpeg-7.1`) and contains:

| File | System | Made by |
|---|---|---|
| `ffmpeg-7.1-win-x64-lgpl.zip` | Windows x64 (also Windows on ARM, under emulation) | `repackage-btbn.yml` from BtbN `win64-lgpl` |
| `ffmpeg-7.1-linux-x64-lgpl.tar.gz` | Linux x64 | `repackage-btbn.yml` from BtbN `linux64-lgpl` |
| `ffmpeg-7.1-linux-arm64-lgpl.tar.gz` | Linux arm64 | `repackage-btbn.yml` from BtbN `linuxarm64-lgpl` |
| `ffmpeg-7.1-osx-x64-lgpl.tar.gz` | macOS Intel | `build-macos.yml` |
| `ffmpeg-7.1-osx-arm64-lgpl.tar.gz` | macOS Apple silicon | `build-macos.yml` |
| `checksums.txt` | SHA-256 of every file | both workflows |

Every archive has the tool at `bin/ffmpeg` (`bin/ffmpeg.exe` on Windows), plus `LICENSE`,
`BUILDINFO.txt` (FFmpeg and LAME versions and the configure line) and `SOURCE.txt`.

## Rules

- **LGPL only.** Builds use `--disable-gpl --disable-nonfree` (BtbN's `lgpl` variants do the
  same). GPL and non-free builds are never published.
- **MP3 support.** Every build must list `libmp3lame` in `ffmpeg -encoders`; the workflows fail
  otherwise.
- **Pinned inputs.** The BtbN release tag and the FFmpeg and LAME source tarballs (with their
  SHA-256) are fixed in the workflows; updating them is a reviewed change.
- **Source.** `SOURCE.txt` in each archive and each release note link to the exact FFmpeg and LAME
  sources used. This is the LGPL "corresponding source".

## Publishing a new version

1. Update the pinned inputs and run both workflows (Actions → Run workflow) with the new tag, for
   example `ffmpeg-7.1`: `repackage-btbn.yml` uses BtbN's newest dated build unless a BtbN release tag is given, and records the tag in `BUILDINFO.txt`; in
   `build-macos.yml` set `FFMPEG_SHA256` to the checksum published with the FFmpeg source tarball
   (the workflow refuses to build until it matches).
2. Check the release: all five archives and `checksums.txt`.
3. Join the per-workflow checksum files into one (`cat checksums-*.txt > checksums.txt`), then, in
   the RainyDM repository, record the checksums:
   `scripts/record-checksums.sh checksums.txt path/to/RainyDM/src/Infrastructure/RainyDM.Infrastructure/MediaTools/MediaToolManifest.cs`
   and commit the change. Until a checksum is recorded, RainyDM reports the tool as not available
   on that system (Linux still uses a system FFmpeg 5 or later).
4. Set `MediaTools:BaseUrl` in RainyDM's `appsettings.json` to
   `https://github.com/DevAI48/RainyDM-media-tools/releases/download/`.

## License

FFmpeg is licensed under the LGPL v2.1 or later and LAME under the LGPL; see
[LICENSES/LGPL-2.1.txt](LICENSES/LGPL-2.1.txt). The workflows in this repository are MIT.
