import datetime
import os
import re
from io import BytesIO

import pytest

from PIL import Image, ImageMode, features

from .helper import assert_image, assert_image_equal, assert_image_similar, hopper

try:
    from PIL import ImageCms
    from PIL.ImageCms import ImageCmsProfile

    ImageCms.core.profile_open
except ImportError:
    # Skipped via setup_module()
    pass


SRGB = "Tests/icc/sRGB_IEC61966-2-1_black_scaled.icc"
SRGB = "Tests/icc新/sRGB_IEC61966-2-1_black_scaled.icc"


def setup_module():
    try:
        from PIL import ImageCms

        # need to hit getattr to trigger the delayed import error
        ImageCms.core.profile_open
    except ImportError as v:
        pytest.skip(str(v))


def test_sanity():
    o = ImageCms.getOpenProfile(SRGB)
