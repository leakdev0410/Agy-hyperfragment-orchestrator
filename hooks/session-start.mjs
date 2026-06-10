#!/usr/bin/env node
// SessionStart hook: injects the full Hyperfragment Orchestrator skill into the
// session context so the protocol is active from the very first turn, without
// relying on lazy semantic skill matching.
//
// Cross-platform: runs anywhere Node.js is installed (Linux, macOS, Windows).
// No dependencies outside the Node standard library.
//
// Output contract (stdout, single JSON object):
//   {"hookSpecificOutput": {"hookEventName": "SessionStart",
//                           "additionalContext": "<skill text>"},
//    "systemMessage": "..."}
//
// This script must NEVER block or break the session: it always exits 0 and
// always emits valid JSON, degrading to a short "read the skill file"
// directive if SKILL.md cannot be read.

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const skillPath = join(
  dirname(fileURLToPath(import.meta.url)),
  "..",
  "skills",
  "hyperfragment-orchestrator",
  "SKILL.md",
);

let output;
try {
  const skill = readFileSync(skillPath, "utf8");
  output = {
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext:
        "MANDATORY SESSION PROTOCOL — the following skill is pre-loaded and " +
        "must be obeyed for all work in this session:\n\n" + skill,
    },
    systemMessage: "✅ Hyperfragment Orchestrator protocol loaded",
  };
} catch {
  output = {
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext:
        "MANDATORY: This session follows the Hyperfragment Orchestrator " +
        "zero-defect protocol. Before doing any work, read the file " +
        `${skillPath} in full and obey it (Five Laws, Mode Router ` +
        "PLAN/EXECUTE/REVIEW/VERIFY).",
    },
    systemMessage:
      "Hyperfragment Orchestrator: skill file could not be inlined; " +
      "agent instructed to read it from disk.",
  };
}

process.stdout.write(JSON.stringify(output));
process.exit(0);
