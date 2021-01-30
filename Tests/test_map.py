import pytest

from PIL import Image


def test_tobytes():
    with Image.open("Tests/images/l2rgb_read.bmp") as im:
        with pytest.raises((ValueError, MemoryError, OSError)):
            im.tobytes()
