#!/bin/bash

# gather the coverage data
if [ "$DOCKER" ]; then
    echo "torch1"
    sudo apt-get update
    echo "torch2"
    pip install coverage
    echo "torch3"
fi
echo "torch4"
sudo apt-get -qq install lcov
echo "torch5"
lcov --capture --directory . -b . --output-file coverage.info
echo "torch6"
#  filter to remove system headers
lcov --remove coverage.info '/usr/*' -o coverage.filtered.info
#  convert to json
echo "torch7"
gem install coveralls-lcov
echo "torch8"
coveralls-lcov -v -n coverage.filtered.info > coverage.c.json
echo "torch9"

coverage report
echo "torch10"
pip install codecov
echo "torch11"
pip install coveralls-merge
echo "torch12"
coveralls-merge coverage.c.json
echo "torch13"
codecov
echo "torch14"

if [ "$TRAVIS_PYTHON_VERSION" == "2.7" ] && [ "$DOCKER" == "" ]; then
    # Coverage and quality reports on just the latest diff.
    # (Installation is very slow on Py3, so just do it for Py2.)
    depends/diffcover-install.sh
    depends/diffcover-run.sh
fi
