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

# Or from a local clone (useful for development):
git clone https://github.com/leakdev0410/Agy-hyperfragment-orchestrator
agy plugin install ./Agy-hyperfragment-orchestrator     # or: agy plugin link
agy plugin enable hyperfragment-orchestrator
```

Verify the bundle before/after installing:

```sh
agy plugin validate ./Agy-hyperfragment-orchestrator
agy plugin list
```

## How auto-activation works / Cơ chế tự kích hoạt

Two independent layers (belt-and-suspenders):

1. **`SessionStart` hook** ([`hooks/hooks.json`](hooks/hooks.json) →
   [`hooks/session-start.sh`](hooks/session-start.sh)): on every new session,
   the hook injects the **full text of `SKILL.md`** into the agent's context
   via `hookSpecificOutput.additionalContext`, so the protocol is active from
   the very first turn. The script JSON-encodes the skill with `python3`
   (falling back to `jq`, then `node`); if none of those exist, it still emits
   a valid directive telling the agent to read the skill file from disk. It
   always exits 0 and never blocks the session.
2. **Always-on rule** ([`rules/hyperfragment-orchestrator.md`](rules/hyperfragment-orchestrator.md)):
   prepended to every prompt by the plugin's `rules/` mechanism. It restates
   the non-negotiable core (evidence-bound claims, no APIs from memory,
   UNKNOWN over guessing) and instructs the agent to read `SKILL.md` if the
   hook did not run — a fallback for `agy` versions where hook events differ.

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
  `./hooks/session-start.sh | python3 -m json.tool > /dev/null && echo OK`

## Layout

```
plugin.json                                 # plugin manifest
hooks/hooks.json                            # registers the SessionStart hook
hooks/session-start.sh                      # injects SKILL.md into session context
rules/hyperfragment-orchestrator.md         # always-on fallback rule
skills/hyperfragment-orchestrator/SKILL.md  # the full protocol (verbatim)
```

## Compatibility notes

Antigravity CLI's plugin surface is still evolving (mid-2026). Two things to
re-check against [antigravity.google/docs](https://antigravity.google/docs/plugins)
if a new `agy` release changes behavior:

- The canonical hook **event names** (`SessionStart` is confirmed in real-world
  plugins such as Microsoft's agent-governance-toolkit, but some sources show
  `BeforeAgent`/`PreInvocation` variants). If the hook stops firing, the
  `rules/` fallback keeps the protocol enforced.
- The full official `plugin.json` schema; this manifest uses the universally
  observed fields (`name`, `version`, `description`, `author`).

The hook script requires a POSIX shell (macOS/Linux/WSL/Git Bash).
