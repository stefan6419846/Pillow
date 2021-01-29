import io
import os
import shutil
import tempfile

import pytest

import PIL
from PIL import Image, ImageDraw, ImagePalette, ImageShow, UnidentifiedImageError

from .helper import (
    assert_image_equal,
    assert_image_similar,
    assert_not_all_same,
    hopper,
    is_win32,
    skip_unless_feature,
)


class TestImage:
    def test_suggestion(self):
        with Image.open("Tests/images/l2rgb_read.bmp") as im:
            im.tobytes()
