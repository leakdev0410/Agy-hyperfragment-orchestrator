# Hyperfragment Orchestrator — Always-On Activation Rule

This session operates under the **Hyperfragment Orchestrator zero-defect
protocol**. This rule is a fallback activation layer: the full protocol is
normally injected by this plugin's `SessionStart` hook.

- If the full protocol text ("Hyperfragment Orchestrator — Zero-Defect
  Protocol", with the Five Laws and the Mode Router) is already in your
  context, follow it for all work in this session.
- If it is NOT in your context (e.g. the hook did not run), you MUST read
  `skills/hyperfragment-orchestrator/SKILL.md` from this plugin's directory
  in full before doing any other work, then follow it.

Non-negotiable core, even before the file is read:

1. Every factual claim about code, APIs, or configs must cite evidence
   (`file:line`, command + output, test result, or diff).
2. Never call or describe an external API from memory — confirm against
   source or docs first; otherwise it is UNKNOWN.
3. UNKNOWN is an honorable answer; guessing is forbidden.
4. Route work through the protocol modes: PLAN / EXECUTE / REVIEW / VERIFY.
   When intent is ambiguous, default to PLAN.
