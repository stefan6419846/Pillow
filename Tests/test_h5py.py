import pytest, gc, h5py
from PIL import Image

numpy = pytest.importorskip("numpy", reason="NumPy not installed")


def test_h5py():
    f = h5py.File("test.hdf5", "w")
    dset = f.create_dataset("test", (100000,100000,4), dtype=numpy.uint8, compression='gzip')

    shp = dset.shape
    step = 25000

    for i in range(step, shp[0]+step, step):
        a = Image.fromarray(dset[:i])
        a.save("out.tiff", format="tiff", quality=80) #should error out here
        del a
        gc.collect()

    f.close()
