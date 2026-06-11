# Agy Hyperfragment Orchestrator

An [Antigravity CLI](https://antigravity.google/product/antigravity-cli) (`agy`)
plugin that **auto-activates the Hyperfragment Orchestrator zero-defect
protocol at the start of every session** — no manual skill invocation, no
reliance on lazy semantic skill matching.

The protocol (PLAN / EXECUTE / REVIEW / VERIFY) recursively fragments any
coding task into atomic, evidence-bound steps and cross-verifies every claim
through independent verifiers. Full text:
[`skills/hyperfragment-orchestrator/SKILL.md`](skills/hyperfragment-orchestrator/SKILL.md).

## Install / Cài đặt

```sh
# From this repository:
agy plugin install https://github.com/leakdev0410/Agy-hyperfragment-orchestrator
agy plugin enable hyperfragment-orchestrator

# Or from a local clone (most reliable; required on macOS — see Troubleshooting):
git clone https://github.com/leakdev0410/Agy-hyperfragment-orchestrator
agy plugin install ./Agy-hyperfragment-orchestrator     # or: agy plugin link
agy plugin enable hyperfragment-orchestrator
```

Verify the bundle before/after installing:

```sh
agy plugin validate ./Agy-hyperfragment-orchestrator
agy plugin list
```

### Troubleshooting: `unsupported extension format` / Lỗi khi cài qua URL

`agy plugin install <github-url>` clones the repo into a temp directory and
then detects the bundle format by looking for a **`gemini-extension.json`**
marker at the repo root (the URL installer is inherited from Gemini CLI's
extension downloader). If that file is missing, install fails with:

```
Error: failed to process downloaded plugin: unsupported extension format at <temp dir>
```

This repo ships `gemini-extension.json` (mirroring `plugin.json`) precisely so
the URL install path works. If you still hit the error:

- **Update `agy`** — older releases (≤ 1.0.5) reject some URL installs
  outright.
- **macOS**: a known `agy` bug mis-resolves the `/var` → `/private/var`
  symlink for the temp clone and reports the same error regardless of repo
  contents. Use the local-clone install above.
- **Fallback (always works)**: clone the repo yourself and run
  `agy plugin install ./Agy-hyperfragment-orchestrator`.

## How auto-activation works / Cơ chế tự kích hoạt

Two independent layers (belt-and-suspenders):

1. **`SessionStart` hook** ([`hooks/hooks.json`](hooks/hooks.json) →
   [`hooks/session-start.mjs`](hooks/session-start.mjs)): on every new session,
   the hook injects the **full text of `SKILL.md`** into the agent's context
   via `hookSpecificOutput.additionalContext`, so the protocol is active from
   the very first turn. `hooks.json` uses Antigravity's named-hook-group
   format — a top-level group key (`hyperfragment-orchestrator`) carrying
   `"enabled": true` and the `SessionStart` event array. (The earlier
   `{"hooks": {"SessionStart": …}}` wrapper is Claude Code's shape; `agy`
   does not recognize it, so the hook silently never registered.) The hook is
   a dependency-free Node.js (ESM) script — it runs identically on Linux,
   macOS, and Windows. If `SKILL.md` cannot be read it still emits a valid
   directive telling the agent to read the skill file from disk. It always
   exits 0 and never blocks the session.
2. **Extension context file** ([`rules/hyperfragment-orchestrator.md`](rules/hyperfragment-orchestrator.md)):
   declared via `contextFileName` in both
   [`gemini-extension.json`](gemini-extension.json) and
   [`plugin.json`](plugin.json). An extension's context file is loaded into
   the model's context **in every session where the extension is active** —
   no slash command, no trigger phrase, no semantic match required. It
   restates the non-negotiable core (evidence-bound claims, no APIs from
   memory, UNKNOWN over guessing) and instructs the agent to read `SKILL.md`
   if the hook did not run — a fallback for `agy` versions where hook events
   differ. (Without `contextFileName`, a bare `rules/` directory is **not**
   auto-loaded by `agy`; the file just sat on disk, which is why the protocol
   previously activated only when the user happened to type a skill trigger
   such as "siêu phân mảnh".)

The skill also ships normally under `skills/`, so semantic matching
("plan this", "review this PR", "không được sai", …) works as usual even if
both layers above are disabled.

## Checking it works / Kiểm tra

```sh
agy   # start a new session
```

- You should see the system message `✅ Hyperfragment Orchestrator protocol loaded`.
- Ask the agent *"what protocol are you following?"* — it should answer with
  the Five Laws and the PLAN/EXECUTE/REVIEW/VERIFY mode router.
- Hook output can be tested standalone:
  `node hooks/session-start.mjs | python3 -m json.tool > /dev/null && echo OK`

## Layout

```
plugin.json                                 # plugin manifest
gemini-extension.json                       # marker required by `agy plugin install <url>`
hooks/hooks.json                            # registers the SessionStart hook
hooks/session-start.mjs                     # injects SKILL.md into session context
rules/hyperfragment-orchestrator.md         # always-on context file (contextFileName)
skills/hyperfragment-orchestrator/SKILL.md  # the full protocol (verbatim)
```

## Compatibility notes

Antigravity CLI's plugin surface is still evolving (mid-2026). Two things to
re-check against [antigravity.google/docs](https://antigravity.google/docs/plugins)
if a new `agy` release changes behavior:

- The canonical hook **event names** (`SessionStart` is confirmed in real-world
  plugins such as Microsoft's agent-governance-toolkit, but some sources show
  `BeforeAgent`/`PreInvocation` variants). If the hook stops firing, the
  `contextFileName` fallback keeps the protocol enforced.
- The full official `plugin.json` schema; this manifest uses the universally
  observed fields (`name`, `version`, `description`, `author`).
- The dual manifest: `plugin.json` is read by the plugin system, while
  `gemini-extension.json` is what the **URL installer** validates when it
  processes the cloned repo (its absence is the documented cause of
  `unsupported extension format`, e.g. in the agy-hud plugin's architecture
  notes). Both must agree on `name`/`version`, and both carry
  `contextFileName` so whichever manifest the runtime reads loads the
  always-on context file. If a future `agy` release unifies the two, keeping
  both files remains harmless.

The hook requires [Node.js](https://nodejs.org) (any maintained version) on
`PATH`. If Node is absent, the hook fails silently and the `contextFileName`
fallback layer still enforces the protocol.
