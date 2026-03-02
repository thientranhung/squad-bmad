#!/bin/bash
set -e

# Read the full JSON input from Claude Code
HOOK_INPUT=$(cat)

# Temporarily log to analyze the JSON structure of Agent Teams (helps improve the filter later)
echo "$HOOK_INPUT" >> /tmp/claude_stop_hook_debug.jsonl

# Extract the Agent name (if present in the Experimental Agent Teams payload)
AGENT_NAME=$(echo "$HOOK_INPUT" | jq -r '.agent // empty')

# Temporarily log to inspect the actual structure.
# Once /tmp/claude_stop_hook_debug.jsonl has been analysed, enable the Sub-agent filter logic here.
# Example: if [ -n "$AGENT_NAME" ] && [ "$AGENT_NAME" != "root" ]; then exit 0; fi

# --- Dynamic Gemini session target ---
# Derive the tmux session name from the project ROOT folder name.
# We use `git rev-parse --show-toplevel` to resolve from any subdirectory
# to the git root, then take its basename.
# Convention: gemini-orchestrator-<folder-name>  (e.g. cwd=/…/squad-bmad/frontend → gemini-orchestrator-squad-bmad)
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  echo "[wakeup-gemini] Warning: cwd not found in hook payload. Skipping." >&2
  exit 0
fi

# Resolve to git root so subdirectories (e.g. frontend/) don't break session lookup
GIT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -n "$GIT_ROOT" ]; then
  FOLDER_NAME=$(basename "$GIT_ROOT")
else
  # Fallback: if not inside a git repo, use cwd directly
  echo "[wakeup-gemini] Warning: '$CWD' is not inside a git repo. Falling back to basename of cwd." >&2
  FOLDER_NAME=$(basename "$CWD")
fi

GEMINI_SESSION="gemini-orchestrator-${FOLDER_NAME}"

# Check whether the target tmux session actually exists before sending
if ! tmux has-session -t "$GEMINI_SESSION" 2>/dev/null; then
  echo "[wakeup-gemini] Tmux session '${GEMINI_SESSION}' not found. Skipping wake-up signal." >&2
  exit 0
fi

# Send a wake-up signal to the Gemini session.
# We use C-m to ensure Enter is sent safely.
tmux send-keys -t "${GEMINI_SESSION}:0.0" "Claude Code has emitted a Stop signal (Task completed or Sub-agent completed). Please check and continue the work" C-m
sleep 5
tmux send-keys -t "${GEMINI_SESSION}:0.0" C-m

exit 0
