#!/bin/bash
# tmux-send.sh — Reliably send text to a tmux pane.
#
# USAGE:
#   ./tmux-send.sh <session-name> <message> [wait-seconds]
#
# ARGUMENTS:
#   session-name  — tmux session (will be sanitised and targeted at :0.0)
#   message       — content to send (wrap in quotes if it contains spaces)
#   wait-seconds  — (optional) seconds to wait between text and Enter, default: 5
#
# EXAMPLES:
#   .gemini/scripts/tmux-send.sh "gemini-orchestrator-squad-bmad" "Hello from Claude Code"
#   .gemini/scripts/tmux-send.sh "claude-implement-squad-bmad" "/dev-story" 3

set -e

# ── Load shared helpers ────────────────────────────────────────────────────
source "$(dirname "$0")/_common.sh"

SESSION_NAME="$1"
MESSAGE="$2"
WAIT_SECONDS="${3:-5}"

# Validate required arguments
if [ -z "$SESSION_NAME" ] || [ -z "$MESSAGE" ]; then
  echo "Error: Missing arguments." >&2
  echo "Usage: $0 <session-name> <message> [wait-seconds]" >&2
  exit 1
fi

# Sanitise the session name (in case caller passed raw folder name inside it)
SESSION_NAME=$(sanitize_for_tmux "$SESSION_NAME")
PANE_TARGET="${SESSION_NAME}:0.0"

# Check that the session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Error: Tmux session '$SESSION_NAME' does not exist." >&2
  exit 1
fi

# Send the content
tmux send-keys -t "$PANE_TARGET" "$MESSAGE"

# Wait for the pane to receive and render the text
sleep "$WAIT_SECONDS"

# Send Enter (C-m) — do NOT use 'Enter' or '\n'
tmux send-keys -t "$PANE_TARGET" C-m

echo "Sent to '$PANE_TARGET': $MESSAGE"
