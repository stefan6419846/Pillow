#!/bin/bash

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew install python@3.8
python3.8 -m pip install img2pdf==0.2.3
python3.8 -m pip install Pillow==7.2.0
img2pdf -o sample.pdf Tests/images/hopper.jpg
ls -la
ls -la /usr/bin/img2pdf
cat /usr/bin/img2pdf
