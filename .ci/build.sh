#!/bin/bash

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew install python3.8
python3.8 -m pip install img2pdf
img2pdf -o sample.pdf Tests/images/hopper.jpg
