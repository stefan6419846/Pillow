#!/bin/bash

set -e

if [ $(uname) == "Darwin" ]; then
    export CPPFLAGS="-I/usr/local/miniconda/include";
fi
echo "torchrun"
sudo python3.8 -c "from PIL import Image;from PIL import ImageTk;import tkinter;import numpy as np;root = tkinter.Tk();example_image_array = np.full((100,100), 123, dtype=np.uint8);example_image = Image.fromarray(example_image_array);"
echo "torchrun_end"
