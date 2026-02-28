#!/bin/bash
set -e

MSG="$1"
if [ -z "$MSG" ]; then
  MSG="Claude Code is waiting for confirmation/interaction."
fi

# Send a wake-up signal to the Gemini session
tmux send-keys -t gemini-orchestrator:0.0 "Claude Code Notification: $MSG . Please check and continue the work" C-m
sleep 3
tmux send-keys -t gemini-orchestrator:0.0 C-m

exit 0