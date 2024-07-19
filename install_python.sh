echo $1
if [[ $1 ]]; then
    echo "GOT VERSION"
fi
curl -g https://www.python.org/downloads/source/ -o ./file.html

# # Install python security (for work)
# sudo apt install libssl-dev libsqlite3-dev libbz2-dev libgdbm-dev libncurses5-dev libncursesw5-dev libreadline-dev zlib1g-dev libffi-dev
# sudo apt install python3 python3-pip
# echo python3 --version >> ./output.file
# echo python3-pip --version >> ./output.file


