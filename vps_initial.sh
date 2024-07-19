#!/bin/bash
usage() {
  echo "Usage: $0 [-f] [-s] [-n] [-h]"
  echo "  -s    Include ssh configuration"
  echo "  -n    Include neovim install"
  echo "  -f    Include all"
  echo "  -h    Print this help message"
  exit 1
}

while getopts "fsnh" opt; do
    case $opt in
        f)  
         SSH=true
         NEOVIM=true
         ;; 
        s)
         SSH=true
         ;;
        n)
         NEOVIM=true
         ;;
        h)
         usage
         ;;
    esac
done

# Standart update and upgrade and package install
sudo apt-get update && apt-get upgrade
sudo apt-get install zip unzip curl wget nginx postgresql redis-server tmux build-essential 

# Install neovim
if [[ $NEOVIM = true ]]; then
    echo "installing neovim"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

    echo export PATH="$PATH:/opt/nvim-linux64/bin" > ~/.bashrc
    echo export PATH="$PATH:/opt/nvim-linux64/bin" > ~/.zshrc
    . ~/.bashrc
    . ~/.zshrc
fi

# Configure ssh 
# MAKE SURE YOU HAVE YOUR id_rsa key root dir
if [[ $SSH = true ]]; then
    echo "configuring ssh"
    sudo cp ~/id_rsa ~/.ssh/authorized_keys_fake
    ssh-keygen -t rsa -b 2048 -f "~/.ssh/id_rsa_fake" -N "" -q
    sudo tee /etc/ssh/ssh_config.d/custom.false_conf > /dev/null <<EOL
PasswordAuthentication no
Port 56432
Allowusers $(whoami)
PubkeyAuthentication yes
X11Forwarding yes
PermitRootLogin no
EOL
#    sudo service ssh restart
fi
