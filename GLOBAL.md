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

- Apply [ISO 24495-1:2023](https://www.iso.org/standard/78907.html)
  plain language principles. Give readers the information they need.
  Make it easy to find, understand, and use.
- For technical text in English, follow
  [ASD-STE100](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf)
  rules where applicable. Use its approved vocabulary and permitted
  technical nouns and verbs.
- Write short sentences. Use active voice and consistent terms.
  Put each instruction in a separate sentence.
- Explain unfamiliar terms at first use. Keep the technical meaning accurate.
  Preserve exact names in code, API identifiers, and commands.
- Claim full ASD-STE100 compliance only after checking the text against
  the complete rules and dictionary.
