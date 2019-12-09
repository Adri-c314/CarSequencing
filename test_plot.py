# This import registers the 3D projection, but is otherwise unused.
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import

import matplotlib.pyplot as plt
import numpy as np
from numpy import loadtxt
# Fixing random state for reproducibility
np.random.seed(19680801)

#f =open("Output/PLS/A/064_38_2_EP_RAF_ENP_ch2nb37scores.txt","r")

#contents = f.read()
contents = loadtxt("Output/PLS/A/064_38_2_EP_RAF_ENP_ch2nb38scores.txt",delimiter=" ",unpack=False)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
fig.suptitle("38")
print(contents)


for m in contents:
    print(m)
    xs = m[0],
    ys = m[1],
    zs = m[2],
    ax.scatter(xs, ys, zs)

ax.set_xlabel('RAF')
ax.set_ylabel('EP')
ax.set_zlabel('ENP')

plt.show()
