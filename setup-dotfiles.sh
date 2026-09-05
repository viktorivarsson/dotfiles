setup_link() {
  ln -nfs "$HOME/code/private/dotfiles/$1" "$HOME/${2:-$1}"
}

setup_link ".config/ghostty"
setup_link ".config/nvim"
setup_link ".config/starship.toml"
mkdir -p "$HOME/.config/waystone"
setup_link ".config/waystone/config.toml"
setup_link ".config/brewfile/Brewfile" ".brewfile"
setup_link ".config/x"
setup_link ".tmux.conf"
setup_link ".zshrc"
setup_link ".prototools"

# Claude Code + Codex: shared skills, global instructions, Claude settings
# Codex reads user skills from ~/.agents/skills, not ~/.codex/skills (that path
# is legacy/built-in-only) — see https://www.agensi.io/learn/where-are-codex-cli-skills-stored
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/agents" "$HOME/.agents/skills"

for skill_dir in skills/*/; do
  skill_name=$(basename "$skill_dir")
  setup_link "skills/$skill_name" ".claude/skills/$skill_name"
  setup_link "skills/$skill_name" ".agents/skills/$skill_name"
done

setup_link "GLOBAL.md" ".claude/CLAUDE.md"
setup_link "GLOBAL.md" ".codex/AGENTS.md"
setup_link ".claude/settings.json"

# Impeccable design-QA skill for Claude Code + Codex (installs/updates globally,
# outside the repo — https://github.com/pbakaus/impeccable). Run from $HOME, not
# the repo, so its project-scope hook sidecars don't land in this dotfiles repo.
if command -v npx >/dev/null; then
  (cd "$HOME" && npx --yes impeccable install --providers=claude,codex --global --yes)
else
  echo "npx not installed, skipping impeccable install..."
fi

# Build x binary
bun install --cwd ./scripts/x
bun build --compile --outfile x scripts/x/index.ts && mv x bin/x
