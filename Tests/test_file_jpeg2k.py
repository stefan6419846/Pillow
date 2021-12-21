import os
import re
from io import BytesIO

import pytest

from PIL import Image, ImageFile, Jpeg2KImagePlugin, UnidentifiedImageError, features

from .helper import (
    assert_image_equal,
    assert_image_similar,
    assert_image_similar_tofile,
    is_big_endian,
    skip_unless_feature,
)

EXTRA_DIR = "Tests/images/jpeg2000"

pytestmark = skip_unless_feature("jpg_2000")

test_card = Image.open("Tests/images/test-card.png")
test_card.load()

# OpenJPEG 2.0.0 outputs this debugging message sometimes; we should
# ignore it---it doesn't represent a test failure.
# 'Not enough memory to handle tile data'


def test_16bit_monochrome_jp2_like_tiff():
    with Image.open("Tests/images/16bit.cropped.tif") as tiff_16bit:
        assert_image_similar_tofile(tiff_16bit, "Tests/images/16bit.cropped.jp2", 1e-3)
