#!/bin/bash
usage() {
  echo "Usage: $0 [-f] [-s] [-n] [-h] [-p [version]]"
  echo "  -s    Include ssh configuration"
  echo "  -n    Include neovim install"
  echo "  -u    Update and install packages"
  echo "  -p    Install latest or specific python"
  echo "  -f    Include all but python"
  echo "  -h    Print this help message"
  exit 1
}

while getopts "fsnh" opt; do
    case $opt in
        f)  
         SSH=true
         NEOVIM=true
         UPDATE=true
         ;; 
        s)
         SSH=true
         ;;
        n)
         NEOVIM=true
         ;;
        u)
         UPDATE=true
         ;;
        p)
         PYTHON=true
         PYVER=$OPTARG
         ;;
        h)
         usage
         ;;
    esac
done

# Standart update and upgrade and package install
if [[ $UPDATE = true ]]; then
    sudo apt-get update && apt-get upgrade
    sudo apt-get install zip unzip curl wget nginx postgresql redis-server tmux build-essential -y
fi

# Install neovim
if [[ $NEOVIM = true ]]; then
    echo "INSTALLING NEOVIM"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

    echo export PATH="$PATH:/opt/nvim-linux64/bin" > ~/.bashrc
    . ~/.bashrc
    if [ -d ~/.zshrc ]; then
        echo export PATH="$PATH:/opt/nvim-linux64/bin" > ~/.zshrc
        . ~/.zshrc
    fi
    sudo rm ./nvim-linux64.tar.gz
    sudo git clone https://github.com/polemeest/neovim-python.git ~/.config/nvim/lua/custom
    nvim -c "wq"
fi

# Configure ssh 
# MAKE SURE YOU HAVE YOUR id_rsa key root dir
if [[ $SSH = true ]]; then
    echo "CONFIGURING SSH"
    sudo cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
    ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
    sudo tee /etc/ssh/ssh_config.d/custom.conf > /dev/null <<EOL
PasswordAuthentication no
Port 56432
Allowusers $(whoami)
PubkeyAuthentication yes
X11Forwarding yes
PermitRootLogin no
EOL
   sudo service ssh restart
fi

# Altinstall python
if [[ $PYTHON = true ]]; then
    sudo chmod +x ./install_python.sh
    sudo ./install_python.sh $PYVER
fi
echo "ALL DONE, you're welcome."
