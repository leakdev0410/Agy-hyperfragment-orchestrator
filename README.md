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

One always-on layer, plus semantic matching as backup:

1. **Extension context file** ([`GEMINI.md`](GEMINI.md)): loaded into the
   model's context **in every session where the plugin is active** — the
   documented Gemini-CLI-extension mechanism that `agy` inherits. It is
   wired up twice for redundancy: declared explicitly via `contextFileName`
   in both [`gemini-extension.json`](gemini-extension.json) and
   [`plugin.json`](plugin.json), and named `GEMINI.md` at the repo root so
   it is also picked up by the documented default ("if this property is not
   used but a GEMINI.md file is present in your extension directory, then
   that file will be loaded"). The file unconditionally orders the agent —
   before any other work, regardless of what the user's first message says —
   to read `skills/hyperfragment-orchestrator/SKILL.md` in full, follow it,
   and confirm activation with a `✅ Hyperfragment Orchestrator active` line
   in its first reply. It also restates the non-negotiable core
   (evidence-bound claims, no APIs from memory, UNKNOWN over guessing) so
   the essentials hold even if the skill file cannot be read.
2. **Semantic skill matching** (backup): the skill ships normally under
   `skills/`, so trigger phrases ("plan this", "review this PR", "siêu phân
   mảnh", "không được sai", …) still load the full protocol even if the
   context file is not picked up.

> **Removed in v1.1.0:** the former `SessionStart` hook layer
> (`hooks/hooks.json` + a Node.js script). It depended on Node being on
> `PATH`, on an unverified hook event name, and on `${extensionPath}`
> substitution — and its `hooks.json` used a shape `agy` never registered,
> so it silently did nothing. The context file is the simpler,
> dependency-free, documented mechanism; the plugin is now pure
> Markdown + JSON.

## Checking it works / Kiểm tra

```sh
agy   # start a new session
```

- The agent's **first reply** should begin with
  `✅ Hyperfragment Orchestrator active — mode: <PLAN|EXECUTE|REVIEW|VERIFY>`
  — without you typing any trigger phrase ("siêu phân mảnh" etc. is no
  longer needed).
- Ask the agent *"what protocol are you following?"* — it should answer with
  the Five Laws and the PLAN/EXECUTE/REVIEW/VERIFY mode router.
- `agy plugin list` should show `hyperfragment-orchestrator` (v1.1.0) enabled.

## Layout

```
plugin.json                                 # plugin manifest (contextFileName → GEMINI.md)
gemini-extension.json                       # marker required by `agy plugin install <url>`
GEMINI.md                                   # always-on activation rule, loaded every session
skills/hyperfragment-orchestrator/SKILL.md  # the full protocol (verbatim)
```

## Compatibility notes

Antigravity CLI's plugin surface is still evolving (mid-2026). Things to
re-check against [antigravity.google/docs](https://antigravity.google/docs/plugins)
if a new `agy` release changes behavior:

- **Context-file loading**: `contextFileName` and the root-`GEMINI.md`
  default come from the Gemini CLI extension format that `agy` inherits.
  Whether Antigravity's own `plugin.json` reader honors `contextFileName` is
  unverified — the field is kept there anyway because it is harmless, and
  the root-level `GEMINI.md` default covers the gap. If a future release
  switches the extension convention to `AGENTS.md`, rename the file and
  update both `contextFileName` values.
- The full official `plugin.json` schema; this manifest uses the universally
  observed fields (`name`, `version`, `description`, `author`).
- The dual manifest: `plugin.json` is read by the plugin system, while
  `gemini-extension.json` is what the **URL installer** validates when it
  processes the cloned repo (its absence is the documented cause of
  `unsupported extension format`, e.g. in the agy-hud plugin's architecture
  notes). Both must agree on `name`/`version` and carry the same
  `contextFileName`. If a future `agy` release unifies the two, keeping
  both files remains harmless.

No runtime dependencies: the plugin is pure Markdown + JSON. (The former
Node.js `SessionStart` hook was removed in v1.1.0.)
