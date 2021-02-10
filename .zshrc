source ~/gitstatus/gitstatus.prompt.zsh

alias restart:touchbar="pkill 'Touch Bar agent'"

alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias ls="exa"
alias ll="exa -la"
alias cat="bat"

alias yb="yarn build"
alias ybo="yarn bootstrap"
alias ys="yarn start"
alias yt="yarn test"
alias yr="yarn relay"
alias yr:s="yarn relay:stories"
alias yrw="yarn relay --watch"

alias gst="git status"
alias gl="git pull"
alias gp="git push"
alias gm="git merge"
alias gcm="git checkout master"
alias gc-="git checkout -- ."
alias gco="git checkout"
alias glog="git log --graph --abbrev-commit"

alias dcb="docker-compose build"
alias dcu="docker-compose up"
alias dcr="docker-compose run"

# function remove-untagged-images
    # docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
# end

# function getPortProcess
    # lsof -i :$1
# end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

PROMPT='%F{blue}%1~%f %# '
RPROMPT='$GITSTATUS_PROMPT'  # right prompt: git status

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # ghcid
export PATH="/usr/local/opt/php@7.4/bin:$PATH"

[ -f "/Users/viktorivarsson/.ghcup/env" ] && source "/Users/viktorivarsson/.ghcup/env" # ghcup-env

eval $(/opt/homebrew/bin/brew shellenv)
eval "$(zoxide init zsh)"
