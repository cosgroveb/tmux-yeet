#!/usr/bin/env zsh
# tmux-yeet: Yank (retrieve) parked pane

SCRIPT_DIR=${0:A:h}
source "$SCRIPT_DIR/lib.zsh"

main() {
  emulate -L zsh
  local parking_session
  parking_session=$(get_tmux_option @yeet-parking-session "yeet-parking")

  # Check if parking session exists
  if ! parking_exists "$parking_session"; then
    display_message "Nothing parked (no parking session)"
    return 1
  fi

  # Check if something is actually parked
  if ! has_parked_pane; then
    display_message "Nothing parked"
    return 1
  fi

  # Find the placeholder pane (could be anywhere)
  local placeholder
  placeholder=$(find_placeholder_pane)
  if [[ -z $placeholder ]]; then
    # State is inconsistent - env says parked but no placeholder found
    # Clean up and report
    tmux set-environment -gu YEET_PARKED
    tmux set-environment -gu YEET_CMD
    display_message "Placeholder not found - state cleaned up"
    return 1
  fi

  # Get the command name for the success message
  local cmd raw
  raw=$(tmux show-environment -g YEET_CMD 2>/dev/null)
  cmd=${raw#YEET_CMD=}

  # Swap the parked pane back to where the placeholder is
  # .0 is the first pane in the window (absolute index, ignores pane-base-index)
  if ! tmux swap-pane -s "${parking_session}:{start}.0" -t "$placeholder"; then
    display_message "Yank failed - swap error"
    return 1
  fi

  # Clean up environment variables
  tmux set-environment -gu YEET_PARKED
  tmux set-environment -gu YEET_CMD

  display_message "Yanked $cmd back"
}

main "$@"
