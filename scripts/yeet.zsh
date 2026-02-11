#!/usr/bin/env zsh
# tmux-yeet: Yeet (park) current pane

SCRIPT_DIR=${0:A:h}
source "$SCRIPT_DIR/lib.zsh"

main() {
  emulate -L zsh
  local parking_session
  local yank_key
  parking_session=$(get_tmux_option @yeet-parking-session "yeet-parking")
  yank_key=$(get_tmux_option @yank-key "Y")

  # Check if something is already parked
  if has_parked_pane; then
    display_message "Already have a parked pane - yank first (C-a $yank_key)"
    return 1
  fi

  # Check if current pane is a placeholder (shouldn't yeet the placeholder)
  local current_pane
  current_pane=$(tmux display -p '#{pane_id}')
  if is_placeholder_pane "$current_pane"; then
    display_message "This is a placeholder pane - nothing to yeet"
    return 1
  fi

  # Check if we're in the parking session (would swap with ourselves)
  local current_session
  current_session=$(tmux display -p '#{session_name}')
  if [[ $current_session == "$parking_session" ]]; then
    display_message "Can't yeet from the parking session"
    return 1
  fi

  # Capture command BEFORE swap
  local cmd
  cmd=$(tmux display -p '#{pane_current_command}')

  # Ensure parking session exists
  if ! ensure_parking "$parking_session"; then
    display_message "Failed to create parking session"
    return 1
  fi

  # Execute swap - if this fails, we stop here (no respawn)
  # .0 is the first pane in the window (absolute index, ignores pane-base-index)
  if ! tmux swap-pane -t "${parking_session}:{start}.0"; then
    display_message "Swap failed - pane unchanged"
    return 1
  fi

  # Set global environment variables to track state
  tmux set-environment -g YEET_PARKED 1
  tmux set-environment -g YEET_CMD "$cmd"

  # Respawn the swapped-in pane (now in our position) as placeholder
  # Set pane title as marker, then display banner
  tmux select-pane -T "YEET_PLACEHOLDER"
  tmux respawn-pane -k "${(q)SCRIPT_DIR}/placeholder.zsh ${(q)cmd} ${(q)yank_key}"

  display_message "Yeeted $cmd to parking"
}

main "$@"
