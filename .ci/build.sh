#!/bin/bash

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
sudo apt install img2pdf
img2pdf -o sample.pdf Tests/images/hopper.jpg
ls -la /usr/bin/img2pdf
cat /usr/bin/img2pdf
