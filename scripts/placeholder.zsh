#!/usr/bin/env zsh
# tmux-yeet placeholder display script
# Called by yeet.zsh via respawn-pane

SCRIPT_DIR=${0:A:h}
source "$SCRIPT_DIR/lib.zsh"

main() {
  local cmd=$1
  local yank_key=$2

  clear
  render_yeet_banner "$cmd" "$yank_key"

  # Block forever (placeholder stays until yanked)
  cat
}

main "$@"
