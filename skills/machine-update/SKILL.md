---
name: machine-update
description: Use when the user asks to update/upgrade everything on this machine, update dependencies, or update brew/proto/tmux plugins in one go — e.g. "update my machine", "upgrade everything", "update deps".
metadata:
  short-description: Run the full machine dependency update
---

# machine-update

Run `update-deps` (or `~/code/private/dotfiles/bin/update-deps` if not on
`$PATH`) instead of running `brew upgrade`, `proto upgrade`, or tmux plugin
updates individually. It runs, in order, and stops on first failure:

1. `brew bundle install` against the repo's Brewfile
2. `brew update` + `brew upgrade --yes`
3. `proto upgrade --yes` + `proto install --yes` (skipped if `proto` isn't installed)
4. tmux plugin cleanup + update (`tpm`)

Only fall back to running individual commands (`brew upgrade`, `proto
upgrade`, etc.) if the user asks for just one specific part, or if
`update-deps` fails and you're diagnosing which step broke.
