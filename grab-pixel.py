import pyscreeze
from PIL import ImageGrab


runs = 1000
for i in range(runs):
    print([i, 'start'])
    im = ImageGrab.grab()
    print([i, 'mid'])
    pyscreeze.pixel(0, 0)

print('all {} runs passed'.format(runs))
