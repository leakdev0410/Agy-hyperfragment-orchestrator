#!/bin/sh
# SessionStart hook: injects the full Hyperfragment Orchestrator skill into the
# session context so the protocol is active from the very first turn, without
# relying on lazy semantic skill matching.
#
# Output contract (stdout, single JSON object):
#   {"hookSpecificOutput": {"hookEventName": "SessionStart",
#                           "additionalContext": "<skill text>"},
#    "systemMessage": "..."}
#
# This script must NEVER block or break the session: it always exits 0 and
# always emits valid JSON, degrading to a short "read the skill file" directive
# when no JSON encoder (python3 / jq / node) is available.

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILL_FILE="$SCRIPT_DIR/../skills/hyperfragment-orchestrator/SKILL.md"

emit_fallback() {
  cat <<EOF
{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "MANDATORY: This session follows the Hyperfragment Orchestrator zero-defect protocol. Before doing any work, read the file ${SKILL_FILE} in full and obey it (Five Laws, Mode Router PLAN/EXECUTE/REVIEW/VERIFY)."}, "systemMessage": "Hyperfragment Orchestrator: skill file could not be inlined; agent instructed to read it from disk."}
EOF
}

if [ ! -r "$SKILL_FILE" ]; then
  emit_fallback
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  SKILL_FILE="$SKILL_FILE" python3 - <<'PYEOF' && exit 0
import json, os, sys
path = os.environ["SKILL_FILE"]
with open(path, encoding="utf-8") as f:
    skill = f.read()
context = (
    "MANDATORY SESSION PROTOCOL — the following skill is pre-loaded and must "
    "be obeyed for all work in this session:\n\n" + skill
)
json.dump(
    {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        },
        "systemMessage": "✅ Hyperfragment Orchestrator protocol loaded",
    },
    sys.stdout,
    ensure_ascii=False,
)
PYEOF
fi

if command -v jq >/dev/null 2>&1; then
  jq -Rs --arg msg "✅ Hyperfragment Orchestrator protocol loaded" \
    '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ("MANDATORY SESSION PROTOCOL — the following skill is pre-loaded and must be obeyed for all work in this session:\n\n" + .)}, systemMessage: $msg}' \
    "$SKILL_FILE" && exit 0
fi

if command -v node >/dev/null 2>&1; then
  SKILL_FILE="$SKILL_FILE" node -e '
    const fs = require("fs");
    const skill = fs.readFileSync(process.env.SKILL_FILE, "utf8");
    process.stdout.write(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: "MANDATORY SESSION PROTOCOL — the following skill is pre-loaded and must be obeyed for all work in this session:\n\n" + skill,
      },
      systemMessage: "✅ Hyperfragment Orchestrator protocol loaded",
    }));
  ' && exit 0
fi

emit_fallback
exit 0
