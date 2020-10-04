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

sudo apt-get install clang

tar xvzf tk8.6.10-src.tar.gz
cd tk8.6.10/unix
echo "TORCH1"

export LDFLAGS="-shared-libasan"

FLAGS=()
FLAGS+=("--with-address-sanitizer")
#FLAGS+=("--disable-ipv6")
FLAGS+=("--with-memory-sanitizer")
# installing ensurepip takes a while with MSAN instrumentation, so
# we disable it here
#FLAGS+=("--without-ensurepip")
# -msan-keep-going is needed to allow MSAN's halt_on_error to function
FLAGS+=("CFLAGS=-mllvm -msan-keep-going=1")
FLAGS+=("--with-undefined-behavior-sanitizer")

echo "torch3"
./configure "${FLAGS[@]}" CC="clang"

echo "TORCH2"
make
echo "TORCH3"
sudo make install
echo "TORCH4"
cd ../..

wget https://github.com/python/cpython/archive/v3.8.6.tar.gz
tar zxf v3.8.6.tar.gz
cd cpython-3.8.6/

# Ignore memory leaks from python scripts invoked in the build
#echo "torchrunD2"
#export ASAN_OPTIONS="detect_leaks=0"
#echo "torchrunD25"
#export MSAN_OPTIONS="halt_on_error=0:exitcode=0:report_umrs=0"

# Remove -pthread from CFLAGS, this trips up ./configure
# which thinks pthreads are available without any CLI flags
#echo "torchrunD3"
#CFLAGS=${CFLAGS//"-pthread"/}
#echo "torchrunD4"

FLAGS=()
#FLAGS+=("--with-address-sanitizer")
FLAGS+=("--disable-ipv6")
FLAGS+=("--with-memory-sanitizer")
# installing ensurepip takes a while with MSAN instrumentation, so
# we disable it here
FLAGS+=("--without-ensurepip")
# -msan-keep-going is needed to allow MSAN's halt_on_error to function
FLAGS+=("CFLAGS=-mllvm -msan-keep-going=1")
#FLAGS+=("--with-undefined-behavior-sanitizer")

echo "torch3"
sudo ./configure "${FLAGS[@]}" CC="clang"
echo "torch4"
sudo make -j$(nproc)
echo "torch5"
sudo make install
echo "torch6"
cd ..

echo "torchrunA"
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
echo "torchrunB"
sudo python3.8 get-pip.py
echo "torchrunC"
sudo python3.8 -m pip install numpy
echo "torchrunD"
sudo python3.8 setup.py install
echo "torchrunD1"
