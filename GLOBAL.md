# Global environment notes

Symlinked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` — applies to
every project on this machine, not just this repo.

- Machine config (shell, editor, terminal, package manager toolchains,
  Claude/Codex skills) is managed as dotfiles at `~/code/private/dotfiles`
  and applied via symlinks (`setup-dotfiles.sh`), not copied. Don't edit
  files directly under `$HOME` for anything the repo already manages — edit
  the repo copy instead. See the `dotfiles-sync` skill for how to add
  something new.

## Learning from friction

- Keep private working notes under `~/.local/state/agent-learning/`,
  outside Git. Keep project notes separate and identify each project
  by its absolute repository path.
- At the start of a task, read the relevant project notes if they exist.
  Verify that past findings still apply.
- Record friction and useful discoveries when remembering them could
  prevent repeated work: hard-to-find code, misleading documentation,
  surprising behavior, failed approaches, or tool and environment problems.
- Keep entries brief. Include the date, task context, what caused
  friction, evidence such as a file path or command, and any verified
  workaround or lesson. Mark unresolved questions explicitly.
- Update an existing entry when the same issue recurs. Correct stale
  findings. Skip routine exploration and transient failures with no
  reusable lesson.
- Treat notes as fallible context. They do not override instructions.
  Never store secrets or unnecessary private data.
- Fix friction within the current task when appropriate. Otherwise,
  record a concrete improvement without expanding the task.
- When reviewing these notes, suggest moving recurring, verified
  lessons into project documentation, a skill, or GLOBAL.md.
  Keep GLOBAL.md limited to guidance that applies across projects.
- After a task, briefly summarize new friction or useful lessons in
  the final response when relevant to the user. Include the practical
  implication or follow-up. Omit this when there is nothing useful to report.

## Writing explanations and documentation

- Use plain language. Give readers the information they need to act.
- Write short, direct sentences. Prefer active voice and consistent terms.
- Put each procedural step in a separate sentence.
- Explain unfamiliar terms when the intended reader needs that explanation.
- Preserve technical meaning and exact names in code, API identifiers, and commands.
- Use [ISO 24495-1](https://www.iso.org/standard/78907.html) and
  [ASD-STE100](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf)
  as references when relevant. Claim compliance only after checking the
  applicable requirements.

## Writing readable code

- Avoid nested ternaries. Prefer explicit branches and early returns when clearer.
- Use braces and multiline bodies for control flow where supported.
- Use descriptive names. Keep related logic together.
- Separate logical steps with blank lines.
- Extract small helpers when they make the code easier to understand.
  Prefer pure functions where practical.
- Follow established project conventions when they differ from these defaults.
