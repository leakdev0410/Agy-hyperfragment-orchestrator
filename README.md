# Hyperfragment Orchestrator

A zero-defect engineering protocol plugin for
[opencode](https://github.com/anomalyco/opencode) that **auto-activates the
Hyperfragment Orchestrator protocol at the start of every session** — no
manual skill invocation needed.

The protocol (PLAN / EXECUTE / REVIEW / VERIFY) recursively fragments any
coding task into atomic, evidence-bound steps and cross-verifies every claim
through independent verifiers. Full text:
[`.agents/skills/hyperfragment-orchestrator/SKILL.md`](.agents/skills/hyperfragment-orchestrator/SKILL.md).

## Install / Cai dat

```sh
# Clone into your opencode skills directory:
git clone https://github.com/leakdev0410/Agy-hyperfragment-orchestrator \
  "$env:USERPROFILE\.config\opencode\plugins\hyperfragment-orchestrator"

# Or clone anywhere and configure opencode to load it via AGENTS.md convention
git clone https://github.com/leakdev0410/Agy-hyperfragment-orchestrator
# Add the repo path to your workspace or copy .agents/ into your project
```

OpenCode discovers skills from `.agents/skills/` directories. The
`AGENTS.md` at the repo root provides unconditional session activation.

## Other harnesses / Nen tang khac

The protocol itself is model- and harness-agnostic (see the *Harness
Adaptation* section in
[`.agents/skills/hyperfragment-orchestrator/SKILL.md`](.agents/skills/hyperfragment-orchestrator/SKILL.md)).
To run the protocol on another tool, copy `SKILL.md` into that tool's
instruction surface by hand (Cursor/Cline rules, aider `CONVENTIONS.md`, a
system prompt, etc.).

## How auto-activation works / Co che tu kich hoat

1. **AGENTS.md** — opencode reads `AGENTS.md` from the repo root as
   an always-on context rule. It unconditionally orders the agent — before
   any other work — to invoke the `hyperfragment-orchestrator` skill, follow
   it, and confirm activation with `✅ Hyperfragment Orchestrator active`
   in its first reply. It also restates the non-negotiable core (evidence-bound
   claims, no APIs from memory, UNKNOWN over guessing) so the essentials hold
   even if the skill cannot be loaded.
2. **Skill matching** (backup) — the skill ships under `.agents/skills/`, so
   opencode's skill system can load it on demand. Trigger phrases ("plan
   this", "review this PR", "siêu phân mảnh", "không được sai", ...) still
   load the full protocol.
3. **Redundant skill copy** — `skills/hyperfragment-orchestrator/SKILL.md`
   mirrors the canonical `.agents/skills/` copy for harness portability.

## Checking it works / Kiem tra

Start a new opencode session in any workspace where this plugin is active.
The agent's **first reply** should begin with:
`✅ Hyperfragment Orchestrator active — mode: <PLAN|EXECUTE|REVIEW|VERIFY>`
— without you typing any trigger phrase.

## Layout

```
plugin.json                                 # plugin manifest
AGENTS.md                                   # always-on activation rule, loaded every session
.agents/skills/hyperfragment-orchestrator/SKILL.md  # the full protocol (opencode canonical)
skills/hyperfragment-orchestrator/SKILL.md  # mirror copy for harness portability
```

To change the protocol: edit
`.agents/skills/hyperfragment-orchestrator/SKILL.md`, then copy the same
content into `skills/hyperfragment-orchestrator/SKILL.md` so the mirror stays
byte-identical.

## Notes

No runtime dependencies: the whole bundle is pure Markdown + JSON, and
nothing in it executes code.
