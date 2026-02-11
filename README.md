# tmux-yeet

Yeet a tmux pane to a parking session while preserving your layout. Yank it back when ready.

**Requires:** tmux 3.0+ and zsh

## What it does

When you "yeet" a pane:
1. The pane swaps to a hidden parking session
2. A placeholder with ASCII art takes its place (preserving layout)
3. The placeholder shows what was yeeted and how to get it back

When you "yank":
1. The parked pane swaps back to where the placeholder is
2. Works from any pane - finds the placeholder automatically

## Installation

### With TPM

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'cosgroveb/tmux-yeet'
```

Then press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/cosgroveb/tmux-yeet ~/.tmux/plugins/tmux-yeet
```

Add to `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-yeet/yeet.tmux
```

## Usage

| Key | Action |
|-----|--------|
| `prefix + y` | Yeet current pane to parking |
| `prefix + Y` | Yank parked pane back |

## Configuration

```tmux
# Change keybindings (defaults shown)
set -g @yeet-key 'y'
set -g @yank-key 'Y'

# Change parking session name (default shown)
set -g @yeet-parking-session 'yeet-parking'
```

## Features

- **Layout preservation**: Uses swap-pane so your window layout stays intact
- **Visual placeholder**: ASCII art banner shows what's parked
- **Global yank**: Retrieve your pane from anywhere, not just where you yeeted from
- **Single pane limit**: Only one pane parked at a time (prevents confusion)
- **lolcat support**: Rainbow banner if lolcat is installed (checks PATH and `/usr/games/lolcat` for Debian)

## Edge cases handled

| Situation | Behavior |
|-----------|----------|
| Double yeet | Blocked with message "Already have a parked pane" |
| Yeet the placeholder | Blocked with message "This is a placeholder pane" |
| Yeet from parking session | Blocked with message "Can't yeet from the parking session" |
| Yank with nothing parked | Message "Nothing parked" |
| Placeholder killed externally | State cleaned up, message shown |
| Placeholder exited (Ctrl-C) | State cleaned up on next yank |
| Parking session killed | Yank shows "Nothing parked" |
| Parking session missing | Created automatically on yeet |
| lolcat not installed | Falls back to plain text |

## Potential conflicts

The default `y` binding may conflict with copy-mode yank in some configurations. If you use vim-style copy mode, consider changing the yeet key:

```tmux
set -g @yeet-key 'g'  # or another unused key
```

## License

MIT
