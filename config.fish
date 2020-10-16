# Aliases
alias restart:touchbar="pkill 'Touch Bar agent'"

alias linode="ssh root@172.104.233.220"

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

zoxide init fish | source

function remove-untagged-images
    # docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
end

set PATH $HOME/bin $PATH
set PATH $HOME/.yarn/bin $PATH
set PATH $HOME/.cargo/bin $PATH

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

function getPortProcess
    lsof -i :$1
end


# eval "$(hub alias -s)"

set pure_color_primary (set_color white)
