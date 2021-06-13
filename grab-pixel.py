import pyautogui
from PIL import ImageGrab


runs = 1000
for i in range(runs):
    print([i, 'start'])
    im = ImageGrab.grab()
    print([i, 'mid'])
    pyautogui.pixel(0, 0)

print('all {} runs passed'.format(runs))
