#!/bin/bash

# Installs python 3.9 on Ubuntu 18 machines.
# To run copy into a Ubuntu machine. Can be run as script or line by line.
# Find Python3.9 on the machine here /usr/local/bin/python3.9
# To make Virtual Environment:
# python3.9 -m venv .venv
# . .venv/bin/activate

sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz
tar -xf Python-3.9.10.tgz
cd Python-3.9.10/
./configure --enable-optimizations
make -j8 && sudo make altinstall
python3.9 -V
