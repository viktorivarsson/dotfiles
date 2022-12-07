setup_link() {
    ln -nfs "$HOME/code/dotfiles/$1" "$HOME/${2:-$1}"
}

setup_link ".config/cheat"
setup_link ".config/nvim"
setup_link ".config/brewfile/Brewfile"
setup_link ".tmux.conf"
setup_link ".zshrc"
setup_link "Brewfile"
