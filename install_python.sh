if [[ $1 ]]; then
    echo "GOT VERSION $1"
    version=$1
else
    version=$(curl -s https://www.python.org/downloads/source/ --compressed | grep -i "Latest Python 3 Release" | sed -n 's/.*Python \([0-9.]*\)<\/a>.*/\1/p')
fi

sub=$(echo $version | cut -d '.' -f 1,2)
cd
home=$(pwd)

# Install python packages
sudo apt install libssl-dev libsqlite3-dev libbz2-dev libgdbm-dev libncurses5-dev libncursesw5-dev libreadline-dev zlib1g-dev libffi-dev
# Get python
wget https://www.python.org/ftp/python/$version/Python-$version.tgz ; \
tar xvf Python-$version.tgz ; \
cd Python-$version ; \
# make altinstall
mkdir ~/.python ; \
./configure --enable-optimizations --prefix=/home/$(whoami)/.python ; \
make -j8 ; \
sudo make altinstall
sudo apt install python3 python3-pip
sudo $home/.python/bin/python$sub -m pip install -U pip
# Write paths to rcs
cd
echo export PATH="$PATH:$home/.python/bin/python$sub" >> ~/.bashrc
    . ~/.bashrc
if [ -d ~/.zshrc ]; then
    echo export PATH="$PATH:$home/.python/bin/python$sub" >> ~/.zshrc
    . ~/.zshrc
fi
# make checks
echo python3.12 --version
echo python3.12-pip --version

