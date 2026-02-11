#!/usr/bin/env bash
# tmux-yeet TPM plugin entry point

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

get_tmux_option() {
  local option="$1"
  local default="$2"
  local value
  value=$(tmux show-option -gqv "$option")
  echo "${value:-$default}"
}

main() {
  local yeet_key yank_key

  yeet_key=$(get_tmux_option "@yeet-key" "y")
  yank_key=$(get_tmux_option "@yank-key" "Y")

  # Bind yeet (park pane)
  tmux bind-key "$yeet_key" run-shell "$CURRENT_DIR/scripts/yeet.zsh"

  # Bind yank (retrieve pane)
  tmux bind-key "$yank_key" run-shell "$CURRENT_DIR/scripts/yank.zsh"
}

main
