# OpenCode Cheat Sheet

## CLI Entry Points

| Command | What it does |
|---|---|
| `opencode` | Open the TUI (start fresh session) |
| `opencode [project-path]` | Open TUI with CWD set to a project directory |
| `opencode -c` / `--continue` | Continue the last active session |
| `opencode -s <id>` | Start or resume a specific session |
| `opencode run "message"` | Run a one-shot message, no TUI |

## Slash Commands (TUI)

| Command | What it does |
|---|---|
| `/init` | Create/update `OpenCode.md` memory file at project root |
| `/compact` | Manually trigger session summarization |
| `/models` | List all available models |
| `/connect` / `/credentials` | Manage provider API keys |
| `/xxx` (custom) | Created by `.md` files in `~/.config/opencode/commands/` |

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+N` | New session |
| `Ctrl+A` | Switch sessions |
| `Ctrl+O` | Open model selector |
| `Ctrl+K` | Custom commands menu |
| `Ctrl+C` | Quit |
| `Ctrl+S` | Send message (from editor) |
| `Ctrl+X` | Cancel current operation |
| `Ctrl+L` | View logs |
| `i` | Focus the editor |
| `Enter` (chat) | Send message |
| `Esc` | Close dialog / exit writing mode |
| `?` | Toggle help overlay |
| `Space` | Confirm selection |
| `a` / `A` | Allow permission (single / for session) |
| `d` | Deny permission |
| `↑` / `↓` | Navigate sessions or models |
| `←` / `→` | Switch providers (in model dialog) |

## CLI Utilities

| Command | What it does |
|---|---|
| `opencode stats` | Token usage and cost statistics |
| `opencode export [id]` | Export session data as JSON |
| `opencode import <file>` | Import session from JSON file or URL |
| `opencode debug` | Debugging & troubleshooting |
| `opencode session` | List/manage sessions |
| `opencode models` | List available models from CLI |
| `opencode agent` | Manage agent configurations |
| `opencode upgrade` | Self-upgrade |

## Custom Commands

Drop `.md` files to create slash commands. Two locations:

| Location | Scope | Example |
|---|---|---|
| `~/.config/opencode/commands/` | Global, every project | `user:review.md` → `/review` |
| `<project>/.opencode/commands/` | Project-local only | `project:lint.md` → `/lint` |

The filename (minus `.md`) becomes the command name.

## Session Behavior

- Sessions persist between terminal restarts.
- `-c` continues from where you left off.
- `--fork` branches off a session without polluting the original.
- `Ctrl+A` switches between active sessions in the TUI.
- `Ctrl+N` creates a fresh session.
