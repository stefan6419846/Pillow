#!/bin/bash

set -e

sudo apt-get update
sudo apt-get -qq install libfreetype6-dev liblcms2-dev python3-tk\
                         libffi-dev libjpeg-turbo-progs libopenjp2-7-dev\
                         cmake imagemagick

PYTHONOPTIMIZE=0 pip install cffi
pip install -U pytest
pip install -U pytest-cov
pip install pyroma
pip install test-image-results

# docs only on Python 3.8
if [ "$TRAVIS_PYTHON_VERSION" == "3.8" ]; then pip install -r requirements.txt ; fi

# extra test images
pushd depends && ./install_extra_test_images.sh && popd
