# Leak sweep — 2026-10-27

Repo: `scheissgeist/Rocksmith` (**public**). Scope: the current tree, the full
git history on every ref, and the one GitHub release asset.

## Result

- **Secrets:** none found, in the tree or in history. No key needs rotating.
- **Copyrighted game material:** none. No Ubisoft/Rocksmith files, song audio,
  charts, tabs or vendor code dumps have ever been committed.
- **Personal info:** 4 low-severity findings (below). Two of them were still in
  HEAD and are redacted from the tree in this PR; all of them stay in history.

No finding calls for an urgent history purge. Whether to purge the personal-info
items is Sean's call; see "History purge" at the end.

## Findings

Values are truncated to at most 4 characters on purpose (the repo is public).

| # | Where | Type | In HEAD? | Recommended action |
|---|---|---|---|---|
| 1 | `docs/SESSION_LOG_2026_09_02.md`, added in `97cb6fe`, still in `fd39e18` | PII: Steam account ID in a `Steam\userdata\1920…` path. It maps directly to a Steam profile. | **n** (redacted in this PR) | Removed from tree. Optional history purge (2 commits). |
| 2 | `docs/SESSION_LOG_2026_09_02.md`, added in `97cb6fe`, still in `fd39e18` | PII: Windows username (`C:\Users\sean…`) and local project folder name, in a scratchpad path | **n** (redacted in this PR) | Removed from tree. Optional history purge (2 commits). |
| 3 | `LICENSE`, `README.md`, `TROUBLESHOOTING.md`, `docs/detailed-guide.md` in commits `d2dedaf` through `26cbca6` (removed by `d95334e`) | PII: full real name in copyright and credit lines | n | Already removed from tree by `d95334e`. History purge only if the name itself must go (see #4: the name is also in commit metadata). |
| 4 | Commit metadata of all 11 commits (`d2dedaf` … `fd39e18`) | PII: author/committer email is a personal Gmail address (`sean…@gmail.com`) | n/a (metadata, not a file) | Going forward: turn on GitHub "Keep my email addresses private" and set `git config user.email` to the `@users.noreply.github.com` address. Removing it from past commits needs a history rewrite of every commit. |

Informational, no action needed:

| Where | What | In HEAD? | Notes |
|---|---|---|---|
| `ultimate-installer.exe` (36,355 B, sha256 `b850…`), also the asset on release `1.0` (byte-identical) | Third-party binary: 7-Zip SFX stub (`7zS2.sfx`, Igor Pavlov, LGPL) wrapping a 7z archive, built with BAT2EXE.net | y | Payload is exactly the 5 files in `scripts/` (verified identical after CRLF normalization) plus a `_created_by_bat2exe.net.txt` marker. No secrets, no PII, no game files. The stub is LGPL and fine to redistribute; a one-line "self-extractor by 7-Zip (LGPL)" credit in the README would be the tidy thing. |
| `docs/SESSION_LOG_2026_09_02.md` | Audio endpoint GUIDs, monitor resolution, GPU model, `dxdiagn.dll` versions, first name "Sean" | y | Random per-machine IDs and generic hardware facts. Can't be used to locate or contact anyone. Left as is. |
| `scripts/*` | Download URLs for RS_ASIO (MIT, github.com/mdias) and FL Studio ASIO (Image-Line) | y | Fetched from the upstream at install time, not redistributed. Fine. |
| Small `Rocksmith.ini` / `RS_ASIO.ini` key names and values in docs | Config snippets | y | A few setting names, not game content. Fine. |

## What was scanned

Refs: `main`, `claude/loving-curie-xxp2ql`, tag `1.0`, 11 commits total
(`d2dedaf` 2026-02-21 to `fd39e18` 2026-09-02). Every one of the 31 blobs ever
reachable was dumped and scanned. Also scanned: the extracted payload of
`ultimate-installer.exe`, and the release `1.0` asset (downloaded and hashed).

| Tool / method | Target | Result |
|---|---|---|
| gitleaks 8.21.2, `gitleaks git --log-opts="--all"` | full history, all refs | no leaks |
| gitleaks 8.21.2, `gitleaks dir` | working tree; extracted .exe payload | no leaks |
| trufflehog 3.88.0, `git file://.` (all detectors, no verification) | full history | 0 secrets |
| trufflehog 3.88.0, `filesystem .` | working tree incl. `.git` | 0 secrets |
| grep over all 31 historical blobs | secrets regex: `api[_-]?key`, `secret`, `token`, `passw`, `pwd`, `bearer`, `authorization`, `client_id`, `private key`, `BEGIN … KEY`, `AKIA`, `ghp_`, `gho_`, `github_pat`, `sk-`, `xox[bp]`, `hooks.slack`, `discord(app)?.com/api/webhooks`, `mongodb(+srv)?://`, `postgres(ql)?://`, `mysql://`, `redis://`, `.env`, `.pem`, `credentials` | no hits |
| grep over all 31 historical blobs | PII regex: email addresses, IPv4 addresses, US-style phone numbers, `Users\`, `/home/`, real name, `DESKTOP-`/`LAPTOP-` hostnames, street/address words | findings #1–#3; no emails, IPs or phone numbers in file content |
| filename pass over `git log --all --name-only` | `.env*`, `*.pem`, `*.key`, `credentials*`, `*.psarc`, `*.ogg`, `*.wem`, `*.bnk`, `*.wav`, `*.mp3`, `*.flac`, `*.dll`, `*.sng`, `*.xml`, `*.gp*`, `*.dds`, `*.mdmp`, `*.reg`, `*.csv`, `*.ini` | none ever committed |
| `git log --all --format='%an %ae %cn %ce'` | commit identities | finding #4 |
| `file`, `strings`, py7zr extraction | `ultimate-installer.exe` | 7-Zip SFX + the repo's own scripts; see table above |

## Changes in this PR (tree only)

- `docs/SESSION_LOG_2026_09_02.md`: replaced the Steam account ID and the
  Windows user path with placeholders (findings #1, #2). Nothing else in the
  log changed.
- `.gitignore`: added `.env`, `.env.*` (keeping `.env.example`), `*.pem`,
  `*.key`, `*.p12`, `*.pfx`, `credentials*`, `secrets*`, plus machine-specific
  debug output this project produces: `*.mdmp`, `*.dmp`, `*.reg` (registry
  exports), `audiodump.txt`, `RS_ASIO-log.txt`. No tracked file matches the new
  rules.
- No secrets existed, so there was nothing to move to env vars.
- No history was rewritten and no branches or tags were touched.

## History purge (Sean's decision)

None of this is urgent. If you want the personal info gone from history:

- Findings #1–#3 are text in files: `git filter-repo --replace-text` over the
  two session-log commits (and the early commits for the name).
- Finding #4 needs `git filter-repo --mailmap` (or `--email-callback`) across
  all 11 commits.
- Either way every commit hash changes, so `main` and tag `1.0` need a
  force-push, and release `1.0` would need re-pointing at the new tag commit.
  Forks and clones that already exist keep the old history.
