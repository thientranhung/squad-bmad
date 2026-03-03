#!/bin/bash
# teardown-sessions.sh — Kill the 3 standard tmux sessions for a project.
#
# CONVENTION (matches setup-sessions.sh):
#   gemini-orchestrator-<folder>   → Gemini CLI
#   claude-implement-<folder>      → Claude Code (sonnet)
#   claude-brainstorm-<folder>     → Claude Code (opus)
#
# USAGE:
#   .gemini/scripts/teardown-sessions.sh [folder-name]
#
#   If folder-name is omitted, the name of the git root directory is used.
#
# EXAMPLES:
#   .gemini/scripts/teardown-sessions.sh
#   .gemini/scripts/teardown-sessions.sh squad-bmad

set -e

# ── Load shared helpers ────────────────────────────────────────────────────
source "$(dirname "$0")/_common.sh"

# ── Resolve folder & session names ─────────────────────────────────────────
FOLDER=$(resolve_folder "$1")
derive_session_names "$FOLDER"

# ── Helper: kill session if it exists ─────────────────────────────────────
kill_session_if_exists() {
  local session_name="$1"
  local label="$2"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux kill-session -t "$session_name"
    echo "  [KILLED] $label → session '${session_name}' terminated."
  else
    echo "  [SKIP]   $label → session '${session_name}' not found."
  fi
}

# ── Print plan ────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         squad-bmad  •  Session Teardown                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Project folder : ${FOLDER}"
echo ""
echo "  Sessions to kill:"
echo "    1. ${SESSION_GEMINI}"
echo "    2. ${SESSION_IMPLEMENT}"
echo "    3. ${SESSION_BRAINSTORM}"
echo ""

# ── Kill sessions ─────────────────────────────────────────────────────────
kill_session_if_exists "$SESSION_GEMINI"    "Gemini Orchestrator"
kill_session_if_exists "$SESSION_IMPLEMENT" "Claude Implement (Sonnet)"
kill_session_if_exists "$SESSION_BRAINSTORM" "Claude Brainstorm (Opus)"

# ── Summary ───────────────────────────────────────────────────────────────
echo ""
REMAINING=$(tmux list-sessions 2>/dev/null || true)
if [ -n "$REMAINING" ]; then
  echo "Remaining tmux sessions:"
  echo "$REMAINING" | sed 's/^/  /'
else
  echo "No tmux sessions remaining."
fi
echo ""
