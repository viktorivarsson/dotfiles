# Global environment notes

Symlinked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` — applies to
every project on this machine, not just this repo.

- Machine config (shell, editor, terminal, package manager toolchains,
  Claude/Codex skills) is managed as dotfiles at `~/code/private/dotfiles`
  and applied via symlinks (`setup-dotfiles.sh`), not copied. Don't edit
  files directly under `$HOME` for anything the repo already manages — edit
  the repo copy instead. See the `dotfiles-sync` skill for how to add
  something new.

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
