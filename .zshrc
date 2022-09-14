source ~/gitstatus/gitstatus.prompt.zsh

alias restart:touchbar="pkill 'Touch Bar agent'"

alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias ls="exa"
alias ll="exa -la"
alias cat="bat"
alias vim="/Applications/MacVim.app/Contents/bin/mvim"

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

alias gst="git status"
alias gl="git pull"
alias gp="git push"
alias gm="git merge"
alias gcm="git checkout main || git checkout master"
alias gc-="git checkout -- ."
alias gco="git checkout"
alias glog="git log --graph --abbrev-commit"
alias gclean="git clean -dfX"

alias dcb="docker-compose build"
alias dcu="docker-compose up"
alias dcr="docker-compose run"

alias python=/opt/homebrew/bin/python3

# function remove-untagged-images
    # docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
# end

# function getPortProcess
    # lsof -i :$1
# end
#

function prepare-vnim-sync() {
    echo "Pulling dotfiles repo..."
    git --git-dir ~/code/dotfiles/.git pull
}

function backup-nvim() {
    prepare-vnim-sync
    cp -r ~/.config/nvim/after ~/code/dotfiles/.config/nvim
    cp -r ~/.config/nvim/init.lua ~/code/dotfiles/.config/nvim
    cp -r ~/.config/nvim/lua ~/code/dotfiles/.config/nvim
    cp -r ~/.config/nvim/snippets ~/code/dotfiles/.config/nvim
}

function restore-nvim() {
    prepare-vnim-sync
    cp -r ~/code/dotfiles/.config/nvim/after ~/.config/nvim
    cp -r ~/code/dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua
    cp -r ~/code/dotfiles/.config/nvim/lua ~/.config/nvim
    cp -r ~/code/dotfiles/.config/nvim/snippets ~/.config/nvim
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

PROMPT='%F{blue}%1~%f %# '
RPROMPT='$GITSTATUS_PROMPT'  # right prompt: git status

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # ghcid
export PATH="/usr/local/opt/php@7.4/bin:$PATH"

eval $(/opt/homebrew/bin/brew shellenv)
eval "$(zoxide init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/viktor.ivarsson/.sdkman"
[[ -s "/Users/viktor.ivarsson/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/viktor.ivarsson/.sdkman/bin/sdkman-init.sh"

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export PNPM_HOME="/Users/viktor.ivarsson/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

export DENO_INSTALL="/Users/viktor.ivarsson/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
