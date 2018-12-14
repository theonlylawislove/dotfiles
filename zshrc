#!/usr/bin/env bash

export ZSH="$HOME/.dotfiles/oh-my-zsh"

export RBENV_VERSION=2.5.3
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

if [[ $TERM =~ xterm ]]; then
  # enable ZSH theme
  source /usr/share/powerlevel9k/powerlevel9k.zsh-theme
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh context dir vcs)
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs time)
  POWERLEVEL9K_CONTEXT_TEMPLATE="%n"
fi

plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

export EDITOR=nano

function install-docker() {
  sudo rm -f /etc/docker/daemon.json
  sudo mkdir -p /etc/docker
  sudo touch /etc/docker/daemon.json
  echo "{\"experimental\": true, \"graph\": \"/var/lib/darch/docker\"}" | sudo tee -a /etc/docker/daemon.json
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu bionic stable"
  sudo apt-get install docker-ce
}

eval "$(direnv hook zsh)"

function update-dev-image() {
  # Backup our current image in case the new one is broken.
  sudo darch stage tag pauldotknopf/darch-ubuntu-development:latest pauldotknopf/darch-ubuntu-development:backup --force
  sudo darch images pull pauldotknopf/darch-ubuntu-development:latest
  sudo darch stage upload pauldotknopf/darch-ubuntu-development:latest --force
  sudo darch stage clean
}

# Runs sudo with direnv loaded for the root user
function sudod() {
  sudo direnv exec $PWD /bin/bash -c "$*"
}

function code-root() {
  sudod code --user-data-dir $HOME/.vscode-root $*
}

alias weather='curl -s wttr.in/bradenton' 

function setup-dev-go() {
  # Assumes you manually compiled go
  # at ~/git/go/
  sudo apt-get remove -y golang\*
  sudo ln -s $HOME/git/go/bin/go /usr/bin/go
}

function install-skopeo() {
  echo "deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/projectatomic-ubuntu-ppa-cosmic.list
  sudo apt-get update
  sudo apt-get install skopeo 
}

function install-websocat() {
  curl -Ls https://github.com/vi/websocat/releases/download/v1.2.0/websocat_1.2.0_amd64.deb > /tmp/websocat.deb
  sudo gdebi -n /tmp/websocat.deb
  rm /tmp/websocat.deb
}

function install-ruby() {
  sudo apt-get install -y libssl-dev libreadline-dev
  rbenv install 2.5.3 -s
}

alias gitkraken='(gitkraken -p . > /dev/null 2>&1 &)'

function rider() {
  (bash -c "$HOME/apps/rider/JetBrains\ Rider-2018.2.3/bin/rider.sh $* > /dev/null 2>&1" &)
}

function install-rider() {
  $HOME/.dotfiles/scripts/install-rider.sh
}

alias clipboard='xclip -sel clip'

function download-sample-video() {
  if [ ! -e ~/sample-video.mp4 ]; then
    curl -Ls "https://github.com/pauldotknopf/raspberry-pi-camera-source/releases/download/1.0/arch-echo-color-wheel.mp4" > ~/sample-video.mp4
  fi
}
