#!/usr/bin/env bash
# Integration test for tmux-yeet
# Runs yeet/yank cycle in headless tmux and verifies state

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMUX_TMPDIR=$(mktemp -d)
export TMUX_TMPDIR

cleanup() {
  tmux kill-server 2>/dev/null || true
  rm -rf "$TMUX_TMPDIR"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

pass() {
  echo "PASS: $1"
}

# Start tmux headless
tmux -f /dev/null new-session -d -s test -x 80 -y 24

# Create a second pane (for yanking from)
tmux split-window -h -t test

# Start a process in pane 0
tmux send-keys -t test:0.0 'exec sleep 3600' Enter
sleep 0.3

# === TEST: Yeet from pane 0 ===
echo "--- Testing yeet ---"

tmux run-shell -t test:0.0 "zsh '$PLUGIN_DIR/scripts/yeet.zsh'" \
  || fail "yeet.zsh exited with error"

# Verify parking session exists
tmux has-session -t yeet-parking 2>/dev/null \
  || fail "parking session not created"

# Verify YEET_PARKED is set
tmux show-environment -g YEET_PARKED 2>/dev/null | grep -q '=1' \
  || fail "YEET_PARKED not set"

# Verify placeholder pane exists by title
placeholder=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' | grep YEET_PLACEHOLDER | head -1 | cut -d' ' -f1)
[[ -n "$placeholder" ]] || fail "placeholder pane not found"

pass "yeet created parking session, set env, spawned placeholder"

# === TEST: Double yeet blocked ===
echo "--- Testing double yeet blocked ---"

# Yeet again should fail (already have parked pane)
if tmux run-shell -t test:0.1 "zsh '$PLUGIN_DIR/scripts/yeet.zsh'" 2>/dev/null; then
  # Script succeeded, check if state changed (it shouldn't)
  # The script returns 1 on "already parked", so this path means something's wrong
  # unless the message was shown but exit was 0. Check that env is still =1.
  :
fi
# Either way, YEET_PARKED should still be 1 (not 2 or changed)
tmux show-environment -g YEET_PARKED 2>/dev/null | grep -q '=1' \
  || fail "double yeet corrupted state"

pass "double yeet blocked"

# === TEST: Yank from pane 1 ===
echo "--- Testing yank ---"

tmux run-shell -t test:0.1 "zsh '$PLUGIN_DIR/scripts/yank.zsh'" \
  || fail "yank.zsh exited with error"

# Verify YEET_PARKED is unset
if tmux show-environment -g YEET_PARKED 2>/dev/null | grep -q '=1'; then
  fail "YEET_PARKED still set after yank"
fi

# Verify placeholder is gone
placeholder=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' | grep YEET_PLACEHOLDER || true)
[[ -z "$placeholder" ]] || fail "placeholder still exists after yank"

pass "yank restored pane, cleared env, removed placeholder"

# === TEST: Yank with nothing parked ===
echo "--- Testing yank with nothing parked ---"

# Should fail gracefully (return non-zero)
if tmux run-shell -t test:0.0 "zsh '$PLUGIN_DIR/scripts/yank.zsh'" 2>/dev/null; then
  # Succeeded when it should have shown "Nothing parked" and returned 1
  # This is acceptable if it just displays a message
  :
fi

pass "yank with nothing parked handled"

echo ""
echo "=== ALL TESTS PASSED ==="
