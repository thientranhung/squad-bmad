#!/bin/bash
set -e

MSG="$1"
if [ -z "$MSG" ]; then
  MSG="Claude Code is waiting for confirmation/interaction."
fi

# --- Dynamic Gemini session target ---
# Derive the tmux session name from the project ROOT folder name.
# We use `git rev-parse --show-toplevel` to resolve from any subdirectory
# to the git root, then take its basename.
# Convention: gemini-orchestrator-<folder-name>
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -n "$GIT_ROOT" ]; then
  FOLDER_NAME=$(basename "$GIT_ROOT")
else
  # Fallback: if not inside a git repo, use PWD directly
  echo "[notify-gemini] Warning: not inside a git repo. Falling back to basename of PWD." >&2
  FOLDER_NAME=$(basename "$PWD")
fi

GEMINI_SESSION="gemini-orchestrator-${FOLDER_NAME}"

# Check whether the target tmux session actually exists before sending
if ! tmux has-session -t "$GEMINI_SESSION" 2>/dev/null; then
  echo "[notify-gemini] Tmux session '${GEMINI_SESSION}' not found. Skipping notification." >&2
  exit 0
fi

# Send notification to the Gemini session
tmux send-keys -t "${GEMINI_SESSION}:0.0" "Claude Code Notification: $MSG . Please check and continue the work" C-m
sleep 3
tmux send-keys -t "${GEMINI_SESSION}:0.0" C-m

exit 0