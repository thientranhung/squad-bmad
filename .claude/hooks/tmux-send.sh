#!/bin/bash
# tmux-send.sh — Reliably send text to a tmux pane.
#
# USAGE:
#   ./tmux-send.sh <pane-target> <message> [wait-seconds]
#
# ARGUMENTS:
#   pane-target   — tmux target, e.g.: gemini-orchestrator:0.0
#   message       — content to send (wrap in quotes if it contains spaces)
#   wait-seconds  — (optional) seconds to wait between text and Enter, default: 5
#
# EXAMPLES:
#   ./.claude/hooks/tmux-send.sh "gemini-orchestrator:0.0" "Hello from Claude Code"
#   ./.claude/hooks/tmux-send.sh "cc-implement:0" "/dev-story" 3

set -e

PANE_TARGET="$1"
MESSAGE="$2"
WAIT_SECONDS="${3:-5}"

# Validate required arguments
if [ -z "$PANE_TARGET" ] || [ -z "$MESSAGE" ]; then
  echo "Error: Missing arguments." >&2
  echo "Usage: $0 <pane-target> <message> [wait-seconds]" >&2
  exit 1
fi

# Check that the pane exists
if ! tmux has-session -t "$PANE_TARGET" 2>/dev/null; then
  echo "Error: Tmux target '$PANE_TARGET' does not exist." >&2
  exit 1
fi

# Send the content
tmux send-keys -t "$PANE_TARGET" "$MESSAGE"

# Wait for the pane to receive and render the text
sleep "$WAIT_SECONDS"

# Send Enter (C-m) — do NOT use 'Enter' or '\n'
tmux send-keys -t "$PANE_TARGET" C-m

echo "✓ Sent to '$PANE_TARGET': $MESSAGE"
