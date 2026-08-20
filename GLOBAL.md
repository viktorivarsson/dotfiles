# Global environment notes

Symlinked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` — applies to
every project on this machine, not just this repo.

- Machine config (shell, editor, terminal, package manager toolchains,
  Claude/Codex skills) is managed as dotfiles at `~/code/private/dotfiles`
  and applied via symlinks (`setup-dotfiles.sh`), not copied. Don't edit
  files directly under `$HOME` for anything the repo already manages — edit
  the repo copy instead. See the `dotfiles-sync` skill for how to add
  something new.
