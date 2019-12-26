from io import BytesIO

import pytest
from PIL import Image, Jpeg2KImagePlugin

from .helper import PillowTestCase, is_big_endian, on_ci

codecs = dir(Image.core)

test_card = Image.open("Tests/images/test-card.png")
test_card.load()

# OpenJPEG 2.0.0 outputs this debugging message sometimes; we should
# ignore it---it doesn't represent a test failure.
# 'Not enough memory to handle tile data'


class TestFileJpeg2k(PillowTestCase):
    def setUp(self):
        if "jpeg2k_encoder" not in codecs or "jpeg2k_decoder" not in codecs:
            self.skipTest("JPEG 2000 support not available")

    def test_16bit_monochrome_jp2_like_tiff(self):
        with Image.open("Tests/images/16bit.cropped.tif") as tiff_16bit:
            with Image.open("Tests/images/16bit.cropped.jp2") as jp2:
                self.assert_image_similar(jp2, tiff_16bit, 1e-3)
