from ctypes import windll
from contextlib import contextmanager
from PIL import ImageGrab

@contextmanager
def __win32_openDC(hWnd):
    hDC = windll.user32.GetDC(hWnd)
    print('first', hDC)
    if hDC == 0: #NULL
        raise WindowsError("windll.user32.GetDC failed : return NULL")
    try:
        yield hDC
    finally:
        if hDC < 0:
            hDC = hDC % 2147483647 + 2**31
        print('second', hDC)
        if windll.user32.ReleaseDC(hWnd, hDC) == 0:
            raise WindowsError("windll.user32.ReleaseDC failed : return 0")

def pixel(x, y):
    with __win32_openDC(0) as hdc: # handle will be released automatically
        color = windll.gdi32.GetPixel(hdc, x, y)
        if color < 0:
            raise WindowsError("windll.gdi32.GetPixel failed : return {}".format(color))
        # color is in the format 0xbbggrr https://msdn.microsoft.com/en-us/library/windows/desktop/dd183449(v=vs.85).aspx
        bbggrr = "{:0>6x}".format(color) # bbggrr => 'bbggrr' (hex)
        b, g, r = (int(bbggrr[i:i+2], 16) for i in range(0, 6, 2))
        return (r, g, b)

runs = 1000
for i in range(runs):
    print([i, 'start'])
    im = ImageGrab.grab()
    print([i, 'mid'])
    pixel(0, 0)

print('all {} runs passed'.format(runs))
