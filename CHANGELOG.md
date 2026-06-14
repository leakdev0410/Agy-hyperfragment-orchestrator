# Changelog

## 1.3.0 — 2026-06-14

### Changed

- **Migrated from agy/Gemini CLI to opencode format:**
  - Removed `gemini-extension.json` (Gemini CLI marker)
  - Removed `rules/hyperfragment-activation.md` (agy-native `rules/` surface)
  - Removed `GEMINI.md` (replaced by `AGENTS.md` as primary activation rule)
  - `AGENTS.md` now directly contains the unconditional activation protocol
    instead of being a pointer to `GEMINI.md`
  - Simplified `plugin.json` — removed `contextFileName` (Gemini CLI concept)
  - Updated `README.md` with opencode-specific install and usage instructions

## 1.2.0 — 2026-06-12

### Added

- **Activation redundancy for agy/Gemini CLI** — all idempotent with the
  existing `GEMINI.md` context rule, so the surfaces never stack:
  - `.agents/skills/hyperfragment-orchestrator/SKILL.md` — the official
    Gemini CLI interop copy (byte-identical to the canonical skill);
  - root `AGENTS.md` — a pointer for harnesses that read the
    [AGENTS.md convention](https://agents.md/) instead of `GEMINI.md`;
  - `rules/hyperfragment-activation.md` — an agy-native `rules/` activation
    surface.

### Notes

- The bundle is pure Markdown + JSON; nothing in it executes code.

## 1.1.0

- Replaced the broken Node.js `SessionStart` hook layer with the
  unconditional `GEMINI.md` context rule (`contextFileName` in both
  manifests + root-level default pickup).

## 1.0.0

- Initial release: skill + hook-based activation.
