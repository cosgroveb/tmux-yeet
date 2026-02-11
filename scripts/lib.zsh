#!/usr/bin/env zsh
# tmux-yeet shared library functions

# Get tmux option with default fallback
# Usage: get_tmux_option @option-name default-value
get_tmux_option() {
  local option=$1
  local default=$2
  local value
  value=$(tmux show-option -gqv "$option" 2>/dev/null)
  print -r -- "${value:-$default}"
}

# Display message in tmux status line
display_message() {
  tmux display-message "$1"
}

# Check if parking session exists
parking_exists() {
  local session=$1
  tmux has-session -t "$session" >/dev/null 2>&1
}

# Create parking session if missing, return success/failure
ensure_parking() {
  local session=$1
  if ! parking_exists "$session"; then
    tmux new-session -d -s "$session" >/dev/null 2>&1 || return 1
  fi
  return 0
}

# Check if something is currently parked (env var set)
has_parked_pane() {
  local value
  value=$(tmux show-environment -g YEET_PARKED 2>/dev/null)
  [[ $value == YEET_PARKED=1 ]]
}

# Find the placeholder pane by searching for marker in pane title
# Returns pane_id or empty string
find_placeholder_pane() {
  local pane_id
  # We mark placeholder panes by setting their title to "YEET_PLACEHOLDER"
  pane_id=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' | while read -r id title; do
    if [[ $title == "YEET_PLACEHOLDER" ]]; then
      print -r -- "$id"
      break
    fi
  done)
  print -r -- "$pane_id"
}

# Check if a specific pane is a placeholder
is_placeholder_pane() {
  local pane_id=$1
  local title
  title=$(tmux display -t "$pane_id" -p '#{pane_title}' 2>/dev/null)
  [[ $title == "YEET_PLACEHOLDER" ]]
}

# Find lolcat binary, checking common locations
find_lolcat() {
  if (( $+commands[lolcat] )); then
    print -r -- "lolcat"
  elif [[ -x /usr/games/lolcat ]]; then
    print -r -- "/usr/games/lolcat"
  fi
  # Returns empty if not found
}

# Render the YEET banner with optional lolcat
# Usage: render_yeet_banner "command_name" "yank_key"
render_yeet_banner() {
  local cmd=$1
  local yank_key=$2
  local lolcat
  lolcat=$(find_lolcat)

  local banner
  banner=$(cat <<'BANNER'
██    ██ ███████ ███████ ████████
 ██  ██  ██      ██         ██
  ████   █████   █████      ██
   ██    ██      ██         ██
   ██    ███████ ███████    ██
BANNER
)

  local message="
$banner

🚀 You yeeted $cmd 🚀
C-a $yank_key to bring it back
"

  if [[ -n $lolcat ]]; then
    print -r -- "$message" | "$lolcat"
  else
    print -r -- "$message"
  fi
}
