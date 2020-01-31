#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt install git vim python3-pip
pip3 install ansible 
echo "export PATH='~/.local/bin/':/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games" >> ~/.bashrc
sudo . ~/.bashrc
echo "------------------------------------------------------------------"
ansible --version
