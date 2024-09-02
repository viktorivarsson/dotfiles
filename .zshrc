# PROMPT='%F{blue}%1~%f %F{red}▸%f '

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

# Yarn
alias yd="yarn dev"
alias yyd="yarn && yarn dev"
alias yb="yarn build"
alias ys="yarn start"
alias yt="yarn test"
alias ytw="yarn test --watch"
alias yc="yarn codegen"
alias ycw="yarn codegen --watch"
alias yui="yarn upgrade-interactive --latest"

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

# Sync Dotfiles
function sync-dotfiles() {
    echo "Pulling dotfiles repo..."
    git --git-dir ~/code/dotfiles/.git pull
    ~/code/dotfiles/setup-dotfiles.sh
}

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Custom bin
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/code/dotfiles/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"

# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Homebrew
export HOMEBREW_BUNDLE_FILE="$HOME/.brewfile"
eval $(/opt/homebrew/bin/brew shellenv)

# Zoxide
eval "$(zoxide init zsh)"

# Puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# bun completions
[ -s "/Users/viktor.ivarsson/.bun/_bun" ] && source "/Users/viktor.ivarsson/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Go
export PATH="$PATH:$HOME/go/bin"

# Starship prompt
eval "$(starship init zsh)"


# proto
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
# go
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"

# go
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"
