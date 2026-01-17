setup_link() {
  ln -nfs "$HOME/code/dotfiles/$1" "$HOME/${2:-$1}"
}

setup_link ".config/ghostty"
setup_link ".config/nvim"
setup_link ".config/starship.toml"
setup_link ".config/brewfile/Brewfile" ".brewfile"
setup_link ".config/x"
setup_link ".tmux.conf"
setup_link ".zshrc"
setup_link ".prototools"

deno compile --allow-read --allow-run --allow-env --no-check -o x scripts/x/x.ts && mv x bin/x
deno compile --allow-read --allow-run --allow-env --no-check -o npr scripts/npr/npr.ts && mv npr bin/npr
