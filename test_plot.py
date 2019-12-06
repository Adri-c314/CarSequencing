# This import registers the 3D projection, but is otherwise unused.
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import

import matplotlib.pyplot as plt
import numpy as np

# Fixing random state for reproducibility
np.random.seed(19680801)



fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')


XX1  = [[36, 4, 0],
[35, 22, 0],
[14, 35, 0],
[37, 1, 0],
[18, 33, 0],
[23, 32, 0],
[17, 33, 0],
[13, 36, 0],
[13, 36, 0],
[13, 35, 1],
[12, 37, 1],
[29, 23, 3],
[12, 38, 0],
[12, 38, 0],
[11, 38, 1],
[38, 0, 0],
[24, 31, 0],
[28, 30, 0],
[32, 29, 0],
[17, 30, 3],
[25, 24, 3],
[33, 23, 0],
[21, 27, 3],
[13, 33, 3]]

XX2 = [[16, 29, 0],
[16, 29, 0],
[14, 33, 0],
[12, 36, 1],
[31, 9, 0],
[31, 9, 0],
[30, 14, 1],
[31, 7, 1],
[32, 3, 0],
[13, 35, 0],
[33, 1, 0],
[34, 0, 0],
[12, 38, 0],
[27, 26, 3],
[26, 28, 2],
[28, 27, 2],
[11, 38, 1]]

for m in XX:
    xs = m[0]
    ys = m[1]
    zs = m[2]
    ax.scatter(xs, ys, zs)

ax.set_xlabel('RAF')
ax.set_ylabel('EP')
ax.set_zlabel('ENP')

plt.show()
