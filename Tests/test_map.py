import sys

import pytest

from PIL import Image

from .helper import is_win32


def test_suggestion():
    with Image.open("Tests/images/l2rgb_read.bmp") as im:
        with pytest.raises((ValueError, MemoryError, OSError)):
            im.tobytes()


@pytest.mark.skipif(sys.maxsize <= 2 ** 32, reason="Requires 64-bit system")
def test_ysize():
    numpy = pytest.importorskip("numpy", reason="NumPy not installed")

    # Should not raise 'Integer overflow in ysize'
    arr = numpy.zeros((46341, 46341), dtype=numpy.uint8)
    Image.fromarray(arr)
