import numpy as np
from b3d import B3D

# Create a manually-created B3D object -- see B3D format document for what all these variables mean
b3d = B3D()
b3d.comment = "Creating a manual b3d object for testing"
b3d.lat = np.array([36.5, 36.5, 34.0, 34.0, 31.5, 31.5], dtype=np.double)
b3d.lon = np.array([-84.5, -88.0, -84.5, -88.0, -84.5, -88.0])
b3d.grid_dim = [3, 2]
b3d.time = np.array([100*t for t in range(10)], dtype=np.uint32) 
b3d.ex = np.zeros([10, 6], dtype=np.single)
b3d.ey = np.zeros([10, 6], dtype=np.single)
for t in range(10):
    for i in range(3):
        for j in range(2):
            b3d.ex[t, i*2+j] = t*1000 + i*10+j # Random equation for x e-field
            b3d.ey[t, i*2+j] = -t*1000 - i*10-j # Random equation fo y e-field

# Save B3D object as file
b3d.write_b3d_file("example6by10.b3d")

# Read B3D object
b3d2 = B3D("example6by10.b3d")

# Double the magnitude of the electric field and save again
n = len(b3d2.lat)
nt = len(b3d2.time)
for t in range(nt):
    for i in range(n):
        b3d2.ex[t, i] *= 2
        b3d2.ey[t, i] *= 2
b3d2.write_b3d_file("example6by10_doubled.b3d")

print("Done!")