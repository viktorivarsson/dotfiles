export LANG=en_US.UTF-8

# Navigation
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias l="eza"
alias ls="eza"
alias ll="eza -la"
alias cat="bat"

alias plz="sudo !!"
alias wtf="git status"

# Applications
alias n="nvim"

# Git
alias git='LANG=en git'
alias gst="git status"
alias wtf="git status"
alias gl="git pull"
alias gp="git push"
alias gm="git merge"
alias gcm="git checkout main || git checkout master"
alias gc-="git checkout -- ."
alias gco="git checkout"
alias glog="git log --graph --abbrev-commit"
alias gclean="git clean -dfX"

# Git reset commits
function reset-commits() {
  local count=${1:-1}
  local mode="--soft"
  
  # Handle --hard flag
  if [[ "$1" == "--hard" ]]; then
    mode="--hard"
    count=${2:-1}
  fi
  
  # Validate count is a number
  if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "Error: '$count' is not a valid number"
    return 1
  fi
  
  # Show BIG WARNING for --hard
  if [[ "$mode" == "--hard" ]]; then
    echo "\033[0;31m⚠️  WARNING: --hard reset will permanently lose changes!\033[0m"
    echo "This cannot be undone. Make sure you're certain!"
    echo ""
  fi
  
  # Show commits to be reset
  echo "\033[0;33mResetting last $count commit(s) with --${mode} mode\033[0m"
  echo "\033[0;32mRecent commits to be reset:\033[0m"
  git log -$count --oneline --decorate
  echo ""
  
  # Prompt for confirmation (no Enter required)
  echo -n "\033[1mReset these commits? [y/N]: \033[0m"
  read response
  
  # Only proceed on y/Y
  if [[ "$response" =~ ^[yY]$ ]]; then
    git reset $mode HEAD~$count
    echo "Reset complete."
  else
    echo "\033[0;33mAborted.\033[0m"
  fi
}

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
    (
        echo "Pulling dotfiles repo..."
        cd ~/code/private/dotfiles &&
            git pull &&
            ./setup-dotfiles.sh
    )
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
add_to_path "$HOME/code/private/dotfiles/bin"

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
