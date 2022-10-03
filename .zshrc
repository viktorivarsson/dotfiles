source ~/gitstatus/gitstatus.prompt.zsh

# PROMPT='%F{blue}%1~%f %# '
PROMPT='%F{blue}❯%f '
RPROMPT='$GITSTATUS_PROMPT'  # right prompt: git status

alias restart:touchbar="pkill 'Touch Bar agent'"

# Navigation
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias ls="exa"
alias ll="exa -la"
alias cat="bat"

# Yarn
alias yd="yarn dev"
alias yyd="yarn && yarn dev"
alias yb="yarn build"
alias yyb="yarn && yarn build"
alias ys="yarn start"
alias yt="yarn test"
alias ytw="yarn test --watch"
alias yc="yarn codegen"
alias ycw="yarn codegen --watch"
alias yui="yarn upgrade-interactive --latest"

# Git
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

# Vim config
function prepare-vnim-sync() {
    echo "Pulling dotfiles repo..."
    git --git-dir ~/code/dotfiles/.git pull
}

function backup-nvim() {
    prepare-vnim-sync
    rm -rf ~/code/dotfiles/.config/nvim
    cp -r ~/.config/nvim ~/code/dotfiles/.config/nvim
}

function restore-nvim() {
    prepare-vnim-sync
    rm -rf ~/.config/nvim
    cp -r ~/code/dotfiles/.config/nvim ~/.config/nvim
}

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Custom bin
export PATH="$HOME/bin:$PATH"

# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Haskell
export PATH="$HOME/.local/bin:$PATH" # ghcid

# PHP
export PATH="/usr/local/opt/php@7.4/bin:$PATH"

# Homebrew
eval $(/opt/homebrew/bin/brew shellenv)

# Zoxide
eval "$(zoxide init zsh)"

# Puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# GO
if command -v go &> /dev/null
then
    export PATH=$PATH:$(go env GOPATH)/bin
    export GOPATH=$(go env GOPATH)
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "/Users/$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
