# dotfiles

Machine config for macOS, applied via symlinks (`setup-dotfiles.sh`), not
copies. Run it after cloning, and again (or run `sync-dotfiles`) after
pulling changes.

## Claude Code + Codex

- Skills live in [`agent-skills`](https://github.com/viktorivarsson/agent-skills)
  and are symlinked into both `~/.claude/skills/<name>` and
  `~/.agents/skills/<name>` (Codex reads user skills from `~/.agents/skills`,
  not `~/.codex/skills`). `setup-dotfiles.sh` clones that repo on a new machine
  and runs its installer.
- `GLOBAL.md` — instructions loaded in every project by both tools
  (symlinked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`). Keep it
  short: only things that need to be ambient everywhere, not what a skill's
  own description already triggers on.
- `.claude/settings.json` — Claude Code settings (model, effort, enabled
  plugins), symlinked to `~/.claude/settings.json`.
- [impeccable](https://github.com/pbakaus/impeccable) (design-QA skill) is
  installed/updated globally for both tools by `setup-dotfiles.sh` /
  `bin/update-deps` — it manages itself outside git, not vendored here.

See the `dotfiles-sync` skill for the day-to-day workflow (adding config,
adding skills) once this is set up.
