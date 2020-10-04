#!/bin/bash

aptget_update()
{
    if [ ! -z $1 ]; then
        echo ""
        echo "Retrying apt-get update..."
        echo ""
    fi
    output=`sudo apt-get update 2>&1`
    echo "$output"
    if [[ $output == *[WE]:\ * ]]; then
        return 1
    fi
}
aptget_update || aptget_update retry || aptget_update retry

set -e

sudo apt-get -qq install libfreetype6-dev liblcms2-dev python3-tk\
                         ghostscript libffi-dev libjpeg-turbo-progs libopenjp2-7-dev\
                         cmake imagemagick libasan2

pip install --upgrade pip
PYTHONOPTIMIZE=0 pip install cffi
pip install olefile
pip install numpy

tar xvzf tk8.6.10-src.tar.gz
