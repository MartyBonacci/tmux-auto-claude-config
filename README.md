# tmux-auto-claude-config

Personal dotfiles for a multi-device tmux + Claude Code workflow with **`--permission-mode auto`** — Claude Code's classifier-backed safer mode. Same multi-device persistence story as [tmux-dangerclaude-config](https://github.com/MartyBonacci/tmux-dangerclaude-config), but the wrapper preserves Claude's safety guardrails for everyday use on a real machine.

**Resilient by design**: `install.sh` copies files into your home directory — not symlinks. Delete this repo and everything still works. The repo is just the versioned source, not a runtime dependency.

## How this differs from `tmux-dangerclaude-config`

Both repos give you the same multi-device tmux + Claude Code persistence. The difference is the wrapper:

| | `tmux-dangerclaude-config` | `tmux-auto-claude-config` (this repo) |
|---|---|---|
| Permission flag | `--dangerously-skip-permissions` | `--permission-mode auto` |
| Approval prompts | None — Claude does whatever | Classifier auto-approves common-safe ops; pauses for ~30 categories of risky ones |
| Best for | Dev sandboxes, demos, full-autonomy workflows | Daily-driver use on a real machine with credentials and files you care about |

If `--dangerously-skip-permissions` doesn't make you nervous, the dangerclaude variant has more inertia. If it does, you're in the right repo.

## What's in here

| File | Purpose |
|------|---------|
| `tmux.conf` | Full tmux config: Ctrl+Space prefix, true-color, 50k scrollback, top status bar, mouse on, aggressive-resize, TPM plugins (resurrect, continuum, yank, sensible). |
| `tmux-cheatsheet.txt` | Reference for every keybinding, shell helper, and workflow tip. Run `tcheat` to view it from any terminal. |
| `bashrc.d/10-autoclaude.sh` | `_autoclaude` wrapper function + 8 auto-magical aliases. |
| `bashrc.d/20-tmux-helpers.sh` | `t` / `tl` / `tk` / `ts` / `tcheat` shell helpers and SSH auto-attach. |
| `bashrc.d/30-dsync.sh` | `dsync` function — syncs home config edits back into this repo. |
| `install.sh` | Idempotent setup script — copies files, bashrc injection (with confirmation prompt), TPM clone (pinned to v3.1.0). |

## Install on a new machine

```bash
git clone https://github.com/MartyBonacci/tmux-auto-claude-config.git ~/code-projects/tmux-auto-claude-config
~/code-projects/tmux-auto-claude-config/install.sh
source ~/.bashrc
```

The installer previews the lines it wants to append to `~/.bashrc` and prompts for confirmation. Then inside tmux: press `Ctrl+Space` then `Shift+I` to install plugins via TPM.

### Install options

| Variable | Default | Purpose |
|---|---|---|
| `INSTALL_YES=1` | unset | Skip the `~/.bashrc` confirmation prompt (for non-interactive installs) |
| `TPM_REF=<ref>` | `v3.1.0` | TPM tag/branch to clone — pinned to a known release for supply-chain safety |
| `TMUX_AUTO_ATTACH=0` | unset (=1) | Export in your shell profile to disable the SSH auto-attach into the `main` tmux session |

## How it works

- **Copies, not symlinks**: `install.sh` copies `tmux.conf` → `~/.tmux.conf`, `bashrc.d/*.sh` → `~/.bashrc.d/`, etc. These are real files. Delete this repo and everything keeps running.
- **Modular bashrc**: Your `~/.bashrc` gets a small sourcing loop appended (after you confirm) that reads `~/.bashrc.d/*.sh` at every shell start. The rest of `~/.bashrc` is untouched.
- **`~/.dotfiles` symlink**: Optional convenience — just makes `cd ~/.dotfiles` work for git operations. Nothing depends on it.

## The `_autoclaude` aliases

All 8 run: `claude --permission-mode auto --continue --name $DIR --remote-control` with `DISABLE_COMPACT=1`:

| Alias | Reference |
|---|---|
| `autoclaude` | The plain-English "this is the auto-mode wrapper" alias |
| `easybutton` | The Staples "That was easy!" red button |
| `presto` | Magician's "and… done!" |
| `accio` | Harry Potter summoning charm — say what you want, it appears |
| `roomba` | Autonomous vacuum robot — real-world automation that just works |
| `voila` | "There you go!" — the reveal |
| `tada` | "Look what I made!" magic flourish |
| `selfdriving` | The Tesla autopilot of CLI wrappers |

## How auto-mode actually works

`--permission-mode auto` activates Claude Code's classifier-based permission system, which has explicit allow and soft-deny lists. Roughly:

**Auto-approves** (you don't see a prompt):
- Local file operations within the project directory
- Read-only API calls / GET requests
- Installing dependencies declared in your repo's manifests (`requirements.txt`, `package.json`, `Cargo.toml`, etc.)
- Toolchain bootstrap from official one-liners (`rustup`, `bun`, etc.)
- Git push to a feature branch you started or Claude created
- Reads/writes to Claude's own memory directory

**Will pause and ask** (these need your "y"):
- Modifying shell profiles (`.bashrc`, `.zshrc`, etc.) or other Unauthorized Persistence
- Force-pushing or pushing to the default branch
- `curl | bash` / executing remote code
- Production deploys, `kubectl exec` writes, SSH writes to live hosts
- Installing agent-chosen packages (typosquat / supply-chain risk)
- Changing repo visibility to public, publishing packages
- Real-world transactions (purchases, payments, sending messages to external people)
- Adding SSH keys, cron jobs, systemd units, etc.
- Self-modification of agent settings or memory poisoning

**Inspect the full rule set** in your installed Claude Code:

```bash
claude auto-mode defaults    # the upstream defaults
claude auto-mode config      # your effective config (defaults + your overrides)
```

Customize trusted domains/orgs/buckets via the `autoMode` block in `~/.claude/settings.json`.

## Daily workflow

- **Desktop (at home)**: `t` → lands in `main` tmux → `easybutton` → Claude Code in auto mode.
- **Laptop (SSH + Tailscale)**: `ssh desktop` → auto-attached to `main`.
- **Phone (Termux + Tailscale)**: `ssh desktop` → auto-attached to `main`.

Your tmux session never dies on the desktop. Switch devices freely.

## Editing and syncing configs

Edit any installed file normally:

```bash
nano ~/.tmux.conf       # edit the real installed copy
```

Then sync your edits back into the repo:

```bash
dsync                   # copies changed files from ~ back into the repo
cd ~/.dotfiles          # follow convenience symlink to repo
git diff                # review what changed
git add -A && git commit -m "tweak: status bar colors"
git push
```

On the other machine, pull and re-install:

```bash
cd ~/.dotfiles && git pull
./install.sh            # refreshes copies from repo (always safe to re-run)
source ~/.bashrc        # for bashrc.d changes
# inside tmux: Ctrl+Space + r   for tmux.conf changes
```

## What survives what

| Scenario | Effect |
|---|---|
| Delete this repo | All configs keep working. `dsync` warns but nothing breaks. Re-clone to resume syncing. |
| Delete `~/.dotfiles` symlink | Configs still work. `dsync` falls back to checking `~/code-projects/tmux-auto-claude-config/`. |
| Delete `~/.bashrc.d/` | Functions/aliases vanish from new shells. Re-run `install.sh` to restore. |
| Delete `~/.tmux.conf` | Tmux falls back to defaults. Re-run `install.sh` to restore. |

## Prerequisites

- `claude` binary on `$PATH` — Claude Code **v2.1.83 or later** (required for `--permission-mode auto`)
- `tmux` 3.0 or later
- `git` — for TPM plugin cloning
- Tailscale — optional, but it's how the multi-device workflow reaches the desktop

### Auto-mode account requirements

`--permission-mode auto` is gated by Anthropic and requires **all** of the following. If your account doesn't meet them, the `_autoclaude` aliases will fail with an "auto mode unavailable" error at session start.

| Requirement | What's allowed |
|---|---|
| **Plan** | Max, Team, Enterprise, or API. **Not available on Pro.** |
| **Model** | Sonnet 4.6, Opus 4.6, or Opus 4.7 on Team / Enterprise / API plans; **Opus 4.7 only on Max** |
| **Provider** | Anthropic API only — not Bedrock, Vertex, or Foundry |
| **Org policy** | On Team / Enterprise, an admin must enable auto mode in Claude Code admin settings |

Quick check from your shell before installing:

```bash
claude --permission-mode auto -p "echo ready"
```

If it prints `ready`, you're good. If it errors with "auto mode unavailable", one of the requirements above isn't met — see [tmux-dangerclaude-config](https://github.com/MartyBonacci/tmux-dangerclaude-config) for the no-account-gate variant (works on any plan, uses `--dangerously-skip-permissions`), or just use the standard `claude` command without a wrapper.

## Termux note

On Termux, Ctrl+Space doesn't work natively from the soft keyboard. Add a macro button to `~/.termux/termux.properties`:

```properties
extra-keys = [ \
  [{macro: "CTRL SPACE", display: "prefix"}, 'ESC', '/', '-', 'HOME', 'UP', 'END', 'PGUP'], \
  ['TAB', 'CTRL', 'ALT', 'LEFT', 'DOWN', 'RIGHT', 'PGDN'] \
]
```

Then `termux-reload-settings`. If the keyboard disappears after switching sessions, swipe from the left edge and tap KEYBOARD.
