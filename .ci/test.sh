#!/bin/bash

set -e

python -m pytest -s -v -x -W always --cov PIL --cov Tests --cov-report term Tests/test_h5py.py

# Docs
if [ "$TRAVIS_PYTHON_VERSION" == "3.8" ] && [ "$TRAVIS_CPU_ARCH" == "amd64" ]; then
    make doccheck
fi
