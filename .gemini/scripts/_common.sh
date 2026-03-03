#!/bin/bash
# _common.sh — Shared helpers for squad-bmad tmux scripts.
#
# SOURCE this file; do not execute it directly.
#   source "$(dirname "$0")/_common.sh"

# ── sanitize_for_tmux ──────────────────────────────────────────────────────
# Make a string safe for use as a tmux session name.
#   • '.'  → tmux uses it as session.window.pane separator
#   • ':'  → tmux uses it as session:window separator
#   • ' '  → causes quoting headaches in targets
# Replace all of them with underscores.
sanitize_for_tmux() {
  local name="$1"
  name="${name//./_}"
  name="${name//:/_}"
  name="${name// /_}"
  echo "$name"
}

# ── resolve_folder ─────────────────────────────────────────────────────────
# Determine the project folder name (already sanitised for tmux).
#   $1 — explicit folder name (optional; falls back to git root or $PWD)
resolve_folder() {
  local folder
  if [ -n "$1" ]; then
    folder="$1"
  else
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$git_root" ]; then
      folder=$(basename "$git_root")
    else
      folder=$(basename "$PWD")
    fi
  fi
  sanitize_for_tmux "$folder"
}

# ── derive_session_names ───────────────────────────────────────────────────
# Sets SESSION_GEMINI, SESSION_IMPLEMENT, SESSION_BRAINSTORM globals.
#   $1 — sanitised folder name (output of resolve_folder)
derive_session_names() {
  local folder="$1"
  SESSION_GEMINI="gemini-orchestrator-${folder}"
  SESSION_IMPLEMENT="claude-implement-${folder}"
  SESSION_BRAINSTORM="claude-brainstorm-${folder}"
}
