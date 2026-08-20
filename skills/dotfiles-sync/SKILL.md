---
name: dotfiles-sync
description: Use when the user wants a new tool/app config, shell alias, or machine setting tracked across their machines, or says things like "add this to my dotfiles", "sync my config", "set this up on my other machine". Repo lives at ~/code/private/dotfiles.
metadata:
  short-description: Track new machine config in the dotfiles repo
---

# dotfiles-sync

Viktor's machine config (shell, nvim, tmux, ghostty, brewfile, proto,
Claude/Codex skills, etc.) lives in `~/code/private/dotfiles` and is applied
to `$HOME` via symlinks, not copies.

## Adding new config

1. Move the real file/directory into the repo at the equivalent path (e.g. a
   new app config goes under `.config/<app>/`).
2. Add a line to `setup-dotfiles.sh` using the existing `setup_link` helper:
   ```bash
   setup_link ".config/<app>"          # links to $HOME/.config/<app>
   setup_link ".config/<app>/file" "some/other/target"   # explicit target
   ```
3. Run `sync-dotfiles` (a `.zshrc` function: `git pull` + re-run
   `setup-dotfiles.sh`) or just `./setup-dotfiles.sh` directly from the repo
   to (re)create the symlink. `setup_link` uses `ln -nfs`, so it's safe to
   re-run.
4. Commit and push — other machines pick it up next time they run
   `sync-dotfiles`.

## Adding a new Claude/Codex skill

Skills live once at `skills/<name>/SKILL.md` in the repo and are symlinked
into both `~/.claude/skills/<name>` and `~/.codex/skills/<name>` by
`setup-dotfiles.sh` — write the skill there, don't create it directly under
`~/.claude` or `~/.codex`, or it won't propagate to other machines.

Don't suggest copying files instead of symlinking, and don't edit files
directly under `$HOME` for anything the repo already manages — edit the
repo copy and re-run the setup script.
