import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

// Commands that require explicit user confirmation before the agent runs them.
// Matched against the full bash command string the agent passes to the bash tool.
// Add patterns here. Mirrors the Claude Code `permissions.deny` policy
// (git push, npm) — but as a confirm-gate, so a human can still approve one-offs.
const CONFIRM_PATTERNS: RegExp[] = [
  /\bgit\s+push\b/, // git push (any remote/flags)
  /\bnpm\b/, // bare npm — does NOT match "pnpm" (p is a word char, no boundary before n)
  /\bgh\s+repo\s+create\b[\s\S]*--push\b/, // gh repo create --push (pushes local commits)
  /\bgh\s+repo\s+sync\b/, // gh repo sync (pushes to destination repo, --force hard-resets)
  /\bgh\s+pr\s+merge\b/, // gh pr merge (server-side merge commit on remote)
];

// Commands that are hard-blocked (never allowed, even with confirmation).
// Uncomment / extend as needed.
const DENY_PATTERNS: RegExp[] = [
  // /\brm\s+-rf\s+\/(?:\s|$)/, // rm -rf /
];

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, _ctx) => {
    if (!isToolCallEventType("bash", event)) return;
    const cmd = event.input.command ?? "";
    if (!cmd) return;

    for (const re of DENY_PATTERNS) {
      if (re.test(cmd)) {
        return { block: true, reason: `Denied by policy: matches ${re}` };
      }
    }

    for (const re of CONFIRM_PATTERNS) {
      if (re.test(cmd)) {
        const ok = await _ctx.ui.confirm(
          "Command needs confirmation",
          `Allow?\n$ ${cmd}`,
        );
        if (!ok) return { block: true, reason: `User declined: matches ${re}` };
      }
    }
  });
}
