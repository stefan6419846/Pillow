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
                         cmake imagemagick libharfbuzz-dev libfribidi-dev

python3 -m pip install --upgrade pip
PYTHONOPTIMIZE=0 python3 -m pip install cffi
python3 -m pip install coverage
python3 -m pip install olefile
python3 -m pip install -U pytest
python3 -m pip install -U pytest-cov
python3 -m pip install -U pytest-timeout
python3 -m pip install pyroma
python3 -m pip install test-image-results
# TODO Remove condition when numpy supports 3.10
if ! [ "$GHA_PYTHON_VERSION" == "3.10-dev" ]; then python3 -m pip install numpy ; fi

python3 -m pip install opencv-python

# TODO Remove when 3.8 / 3.9 includes setuptools 49.3.2+:
if [ "$GHA_PYTHON_VERSION" == "3.8" ]; then python3 -m pip install -U "setuptools>=49.3.2" ; fi
if [ "$GHA_PYTHON_VERSION" == "3.9" ]; then python3 -m pip install -U "setuptools>=49.3.2" ; fi

# PyQt5 doesn't support PyPy3
# Wheel doesn't yet support 3.10
if [[ $GHA_PYTHON_VERSION == 3.* && $GHA_PYTHON_VERSION != "3.10-dev" ]]; then
  # arm64, ppc64le, s390x CPUs:
  # "ERROR: Could not find a version that satisfies the requirement pyqt5"
    sudo apt-get -qq install libxcb-xinerama0 pyqt5-dev-tools
    python3 -m pip install pyqt5
fi

# webp
pushd depends && ./install_webp.sh && popd

# libimagequant
pushd depends && ./install_imagequant.sh && popd

# raqm
pushd depends && ./install_raqm.sh && popd

# extra test images
pushd depends && ./install_extra_test_images.sh && popd
