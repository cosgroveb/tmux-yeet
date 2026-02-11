#!/usr/bin/env zsh
# tmux-yeet placeholder display script
# Called by yeet.zsh via respawn-pane

SCRIPT_DIR=${0:A:h}
source "$SCRIPT_DIR/lib.zsh"

main() {
  emulate -L zsh
  local cmd=${1:-unknown}
  local yank_key=${2:-Y}

  clear
  render_yeet_banner "$cmd" "$yank_key"

  # Block forever - stdin never closes, so cat waits indefinitely
  # Pane stays alive until killed by yank or user
  cat
}

main "$@"
