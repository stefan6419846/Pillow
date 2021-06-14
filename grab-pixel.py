import pyscreeze
from PIL import ImageGrab


runs = 1000
for i in range(runs):
    try:
        im = ImageGrab.grab()
        pyscreeze.pixel(0, 0)
    except OSError:
        print('failed after {} runs'.format(i))
        exit()

print('all {} runs passed'.format(runs))
