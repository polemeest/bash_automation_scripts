!#/bin/bash

# Standart update and upgrade and package install
sudo apt-get update && apt-get upgrade
sudo apt-get install zip unzip curl wget nginx postgresql redis-server tmux build-essential 

# Install python security (for work)
sudo apt install libssl-dev libsqlite3-dev libbz2-dev libgdbm-dev libncurses5-dev libncursesw5-dev libreadline-dev zlib1g-dev libffi-dev
sudo apt install python3 python3-pip
echo python3 --version >> ./output.file
echo python3-pip --version >> ./output.file

# Install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz

echo export PATH="$PATH:/opt/nvim-linux64/bin" > ~/.bashrc
echo export PATH="$PATH:/opt/nvim-linux64/bin" > ~/.zshrc
. ~/.bashrc
. ~/.zshrc

# Configure ssh 
