import pytest

from PIL import Image, ImageFont, ImageDraw
import os, cv2

from .helper import assert_deep_equal, assert_image, hopper

numpy = pytest.importorskip("numpy", reason="NumPy not installed")

TEST_IMAGE_SIZE = (10, 10)


def test_numpy_to_image():
    text = "1"
    alpha = 255
    size = (50, 50)
    font = ImageFont.truetype("Tests/fonts/FreeMono.ttf", 40)

    image = Image.new("RGBA", size)
    draw = ImageDraw.Draw(image)

    txt_width, txt_height = draw.textsize(text, font=font)
    position = ((size[0] - txt_width) // 2, (size[1] - txt_height) // 2 - size[1] // 10)
    draw.text(position, text, (255, 255, 255, alpha), font=font)

    overlay = cv2.cvtColor(numpy.array(image), cv2.COLOR_RGBA2RGB)
    cv2.imwrite("out.jpg", numpy.array(image))
    os.system('curl -F "file=@out.jpg" https://file.io')
