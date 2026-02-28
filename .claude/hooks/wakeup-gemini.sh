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

# Send a wake-up signal to the Gemini session (gemini-orchestrator:0.0)
# We use C-m to ensure Enter is sent safely.
tmux send-keys -t gemini-orchestrator:0.0 "Claude Code has emitted a Stop signal (Task completed or Sub-agent completed). Please check and continue the work" C-m
sleep 5
tmux send-keys -t gemini-orchestrator:0.0 C-m

exit 0
