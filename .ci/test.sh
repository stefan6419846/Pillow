#!/bin/bash

set -e

python3 -c "from PIL import Image"

python3 -bb -m pytest -s -v -x -W always --cov PIL --cov Tests --cov-report term Tests/test_numpy.py
