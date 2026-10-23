# Worktree cleanup

Run `cleanup-worktrees` from any directory to open the interactive menu. It runs
with Bun, Git, `lsof` and `sqlite3`. `setup-dotfiles.sh` installs the prompt
dependencies and links the command into `~/.local/bin`. The launcher uses the
dotfiles Proto configuration to resolve Bun, preserving your current directory
and avoiding older Bun versions pinned in other projects.

The menu lets you:

1. Choose cleanup or a read-only inventory.
2. Choose T3, a detected Waystone location, or another folder.
3. Set the minimum days, with a default of one day settled for T3.
4. Select eligible worktrees with Space. Press `a` to select all.
5. Review their generated directories and confirm deletion.

The confirmation defaults to no. Ctrl+C exits a prompt without starting cleanup.
When stdin or stdout is not a terminal, a no-argument invocation shows an
inventory and never prompts or deletes.

Waystone locations are detected under `~/code` at group and repository depth, as
well as roots in the shared and local Waystone TOML config and the current
working directory. You can always enter another worktree parent explicitly.

## Measurement and progress

Measurement is always on. The deletion walker reads each entry's allocated size
and adds it to the running total only after that entry is successfully removed.
It counts hardlinked file blocks once across the batch. It never follows
symlinks. This combines size accounting and deletion in one traversal. There are
no full `.t3` scans and no separate `du` pass.

The command logs inventory progress, each worktree, and each generated
directory. During longer removals it prints a progress line about every two
seconds with removed file, directory and symlink counts, the running reported
size, and the observed free-space change. The final summary reports those totals
and free disk space before and after.

An apply run saves a JSON report under
`~/.local/state/cleanup-worktrees/reports/`, or
`$XDG_STATE_HOME/cleanup-worktrees/reports/` when set. Reports include exact
byte totals, generated directories removed, partial directory results, errors,
and the free-space change. Reports are local machine state and stay outside Git.
Use `--report-dir PATH` to select another destination.

APFS clones can share blocks, so reported deleted bytes can exceed the increase
in free disk space. Other disk activity and snapshots can affect that increase.
The reported size is the total for entries deleted, not a new total for `.t3`.

`--measure` is still accepted for older commands and has no effect because
measurement is automatic. The old `--sizes` and `--measure-path` flags are
removed.

## What gets removed

Only ignored directories named `node_modules`, `.turbo`, `.vite` or `dist` at
package roots are eligible, including nested workspace packages. Directories
with tracked descendants are protected. Source, branches, commits, Git metadata,
T3 history, attachments and environment files outside these generated
directories stay in place. T3's state database is opened read-only.

Everything inside an eligible generated directory is disposable, so do not store
personal files there. `.cache`, `.terraform` and `.wrangler` are excluded.
Symlink targets stay in place, including targets outside the worktree.

Uncommitted or untracked files block cleanup. Processes with visible working
directories inside a worktree also block cleanup. Close selected workspaces and
dev servers before applying. Checks run again immediately before trimming each
worktree, but they cannot eliminate filesystem races with concurrent writers. A
deletion error stops the batch and saves completed and partial results.
Previously removed entries are not restored. Whole worktrees are never removed.

Run your normal install and build commands when returning to a trimmed worktree.
For the frontend repository, run `x i` there before resuming development.

## T3 settlement

Every nondeleted T3 thread sharing a worktree path must have been settled for at
least one full day, with no unfinished run. The newest settlement time sets the
cooldown. An unsettled owner, unknown owner or missing timestamp blocks cleanup.

The script reads the current explicit `settledOverride = settled` projection and
settlement timestamps from `~/.t3/userdata/statev2.sqlite`, verified against
T3's thread API. This is an internal schema; T3 updates may require adapting the
reader. Database errors or unsupported values stop cleanup. Automatic settlement
without a persisted explicit override is conservatively excluded.

## Explicit commands

Use these for scripting or a quick read-only check:

```sh
cleanup-worktrees inventory
cleanup-worktrees trim --all-settled
cleanup-worktrees trim --all-settled --apply
cleanup-worktrees trim --worktree frontend/WORKTREE_NAME --apply
```

Explicit commands default to dry-run. Repeat `--worktree` or `--exclude` for
exact selections or exclusions. Use `--days N` for a different threshold.
`--days 0` removes the cooldown but preserves the remaining checks.

Custom roots default to a three-day activity policy and require an explicit
worktree selection for apply:

```sh
cleanup-worktrees inventory --root ~/code/brightsky/.waystone/worktrees
cleanup-worktrees trim --root ~/code/brightsky/.waystone/worktrees \
  --worktree landing/WORKTREE_NAME --apply
```

The age policy uses source mtimes, Git index and HEAD reflog mtimes, and the
latest commit time. These are estimates; reading files alone may leave no
activity signal. Custom roots must contain `project/worktree` folders. Only
linked Git worktrees are accepted. Invalid Git metadata is reported for manual
inspection. An explicit apply batch with inventory errors stops before deleting
anything. The menu omits blocked entries from selection.

Use `--policy settled` to check T3 ownership on another root, and `--t3-db PATH`
to select another T3 database. `--all-settled` is unavailable with the age
policy. For complete worktree removal, use Waystone's own merged-PR cleanup
lifecycle:

```sh
waystone manage --cleanup-merged --list
waystone manage --cleanup-merged
```

No recurring deletion is configured. Run `x t` from this directory for the
tests.
