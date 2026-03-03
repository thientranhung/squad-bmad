#!/bin/bash
# setup-sessions.sh — Create (or reuse) the 3 standard tmux sessions for a project.
#
# CONVENTION:
#   gemini-orchestrator-<folder>   → Gemini CLI  (yolo, gemini-3-pro-preview)
#   claude-implement-<folder>      → Claude Code (sonnet, bypass-permissions)
#   claude-brainstorm-<folder>     → Claude Code (opus,   bypass-permissions)
#
# USAGE:
#   .gemini/scripts/setup-sessions.sh [folder-name]
#
#   If folder-name is omitted, the name of the current working directory is used.
#
# EXAMPLES:
#   .gemini/scripts/setup-sessions.sh
#   .gemini/scripts/setup-sessions.sh squad-bmad

set -e

# ── Load shared helpers ────────────────────────────────────────────────────
source "$(dirname "$0")/_common.sh"

# ── Resolve folder & session names ─────────────────────────────────────────
FOLDER=$(resolve_folder "$1")
derive_session_names "$FOLDER"

# ── Helper: create session only if it does not already exist ─────────────
create_session_if_missing() {
  local session_name="$1"
  local start_cmd="$2"     # command to run inside the new session
  local label="$3"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "  [SKIP]   $label → session '${session_name}' already exists."
  else
    # -d  : start detached
    # -s  : session name
    tmux new-session -d -s "$session_name" -x 220 -y 50
    # Give the shell a moment to initialise before sending the startup command
    sleep 0.5
    tmux send-keys -t "${session_name}:0.0" "$start_cmd" C-m
    echo "  [CREATE] $label → session '${session_name}' created and command sent."
  fi
}

# ── Print plan ────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         squad-bmad  •  Session Setup                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Project folder : ${FOLDER}"
echo ""
echo "  Sessions to create:"
echo "    1. ${SESSION_GEMINI}"
echo "    2. ${SESSION_IMPLEMENT}"
echo "    3. ${SESSION_BRAINSTORM}"
echo ""

# ── 1. Gemini Orchestrator ───────────────────────────────────────────────────
create_session_if_missing \
  "$SESSION_GEMINI" \
  "gemini --yolo --model gemini-3-pro-preview" \
  "Gemini Orchestrator"

# ── 2. Claude Implement (Sonnet) ─────────────────────────────────────────────
create_session_if_missing \
  "$SESSION_IMPLEMENT" \
  "claude --dangerously-skip-permissions --model sonnet" \
  "Claude Implement (Sonnet)"

# ── 3. Claude Brainstorm (Opus) ──────────────────────────────────────────────
create_session_if_missing \
  "$SESSION_BRAINSTORM" \
  "claude --dangerously-skip-permissions --model opus" \
  "Claude Brainstorm (Opus)"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "Done. Active tmux sessions:"
tmux list-sessions 2>/dev/null | sed 's/^/  /'
echo ""
echo "To attach:"
echo "  tmux attach -t ${SESSION_GEMINI}"
echo "  tmux attach -t ${SESSION_IMPLEMENT}"
echo "  tmux attach -t ${SESSION_BRAINSTORM}"
echo ""
