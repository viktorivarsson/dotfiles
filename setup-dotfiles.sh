setup_link() {
    ln -nfs "$HOME/code/dotfiles/$1" "$HOME/${2:-$1}"
}

setup_link ".config/cheat"
setup_link ".config/nvim"
setup_link ".config/starship.toml"
setup_link ".config/brewfile/Brewfile" ".brewfile"
setup_link ".tmux.conf"
setup_link ".zshrc"

deno install -f --allow-read --allow-run ./scripts/npr/npr.ts
