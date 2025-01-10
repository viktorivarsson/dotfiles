
export LANG=en_US.UTF-8

# Navigation
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias l="eza"
alias ls="eza"
alias ll="eza -la"
alias cat="bat"

# Applications
alias n="nvim"

# Git
alias git='LANG=en git'
alias gst="git status"
alias gl="git pull"
alias gp="git push"
alias gm="git merge"
alias gcm="git checkout main || git checkout master"
alias gc-="git checkout -- ."
alias gco="git checkout"
alias glog="git log --graph --abbrev-commit"
alias gclean="git clean -dfX"

# Docker
alias dcb="docker-compose build"
alias dcu="docker-compose up"
alias dcr="docker-compose run"

# Python
alias python=/opt/homebrew/bin/python3

function add_to_path() {
  if [[ -n "$1" ]]; then
    export PATH="$1:$PATH"
  fi
}

# Sync Dotfiles
function sync-dotfiles() {
    echo "Pulling dotfiles repo..."
    git --git-dir ~/code/dotfiles/.git pull
    ~/code/dotfiles/setup-dotfiles.sh
}

function clean-node-modules() {
    echo "Cleaning node_modules..."
    find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
    echo "Done!"
}

if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi

# Custom bin
add_to_path "$HOME/bin"
add_to_path "$HOME/code/dotfiles/bin"

# Homebrew
export HOMEBREW_BUNDLE_FILE="$HOME/.brewfile"
eval $(/opt/homebrew/bin/brew shellenv)

# Zoxide
eval "$(zoxide init zsh)"

# Puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

# bun completions
[ -s "/Users/viktor.ivarsson/.bun/_bun" ] && source "/Users/viktor.ivarsson/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
add_to_path "$BUN_INSTALL/bin"

# Go
add_to_path "$HOME/go/bin"

# Starship prompt
eval "$(starship init zsh)"

# proto
export PROTO_HOME="$HOME/.proto"
add_to_path "$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# go
export GOBIN="$HOME/go/bin"
add_to_path "$GOBIN"

# Deno
add_to_path "$HOME/.deno/bin"
