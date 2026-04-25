# ═══════════════════════════════════════════════════════════════════════════
# _autoclaude wrapper + auto-magical alias rotation
# Part of the tmux-auto-claude-config dotfiles repo.
# ═══════════════════════════════════════════════════════════════════════════

# Auto-mode Claude Code wrapper. Uses --permission-mode auto, which has an
# LLM-based classifier that auto-approves common-safe operations (local file
# edits in the project, declared package installs, read-only API calls, git
# push to feature branches) and pauses for explicit approval on ~30 categories
# of risky actions (modifying shell profiles, force-push, prod deploys,
# curl|bash, agent-chosen package installs, public repo creation, real-world
# transactions, adding SSH keys / cron jobs / systemd units, etc).
# Inspect the rules with `claude auto-mode defaults` or customize via the
# autoMode block in your ~/.claude/settings.json.
#
# Single helper function + 8 aliases — pick whichever name suits your mood.
# All call the same underlying wrapper so logic stays DRY. Features: auto
# permission mode, continue prior session (per-directory), name session after
# current directory, enable remote control, skip compact prompts.
_autoclaude() {
  DISABLE_COMPACT=1 command claude \
    --permission-mode auto \
    --continue \
    --name "$(basename "$PWD")" \
    --remote-control \
    "$@"
}
alias autoclaude='_autoclaude'
alias easybutton='_autoclaude'
alias presto='_autoclaude'
alias accio='_autoclaude'
alias roomba='_autoclaude'
alias voila='_autoclaude'
alias tada='_autoclaude'
alias selfdriving='_autoclaude'
