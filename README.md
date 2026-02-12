# tmux-yeet
![yeet-slack](https://github.com/user-attachments/assets/921b10f6-f88a-4749-8f70-5c8df1d51096)

Claude Code flickers like a strobe light. Having it in peripheral vision while working another pane is somewhere between
distracting and migraine-triggering.

tmux-yeet: park panes without destroying your layout. C-a y to yeet, C-a Y to yank it back.

## What it does

When you "yeet" a pane:
1. The pane swaps to a hidden "parking" session
2. A placeholder takes its place (preserving layout)

When you "yank":
1. The parked pane swaps back to where the placeholder is
2. Works from any pane - finds the placeholder automatically

This only yeets/yanks one thing at a time.

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

## Potential conflicts

The default `y` binding may conflict with copy-mode yank in some configurations. If you use vim-style copy mode, consider changing the yeet key:

```tmux
set -g @yeet-key 'g'  # or another unused key
```

## License

MIT
