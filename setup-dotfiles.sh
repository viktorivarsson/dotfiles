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

bun build --compile --outfile x scripts/x/index.ts && mv x bin/x
