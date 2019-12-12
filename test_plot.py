# This import registers the 3D projection, but is otherwise unused.
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import

import matplotlib.pyplot as plt
import numpy as np
from numpy import loadtxt
# Fixing random state for reproducibility
np.random.seed(19680801)

#f =open("Output/PLS/A/064_38_2_EP_RAF_ENP_ch2nb37scores.txt","r")
# sans learning 10s et sortie si plis de 10
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576001457892e9scores.txt",delimiter=" ",unpack=False)

#contents = f.read()
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch11.576011693453e9scores.txt",delimiter=" ",unpack=False)

#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576070354505e9scores.txt",delimiter=" ",unpack=False)
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576086366612e9scores.txt",delimiter=" ",unpack=False)
# avec ?
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576086613835e9scores.txt",delimiter=" ",unpack=False)

# avec
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576089552333e9scores.txt",delimiter=" ",unpack=False)
#avec learning 10s:
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576092459864e9scores.txt",delimiter=" ",unpack=False)
# avec 10s et sortie si plus de 5
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576092566819e9scores.txt",delimiter=" ",unpack=False)
# avec plus on en trouve plus on continue
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576093964212e9scores.txt",delimiter=" ",unpack=False)
# 10s rejet a 5 pas ouf
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576095974814e9scores.txt",delimiter=" ",unpack=False)
# 10s avec rejet quand 10
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576098254801e9scores.txt",delimiter=" ",unpack=False)
# apprentissage avec temps 10s
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576098735199e9scores.txt",delimiter=" ",unpack=False)
# temps 10s rejet  a 10 c'est sympa ça
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576099295183e9scores.txt",delimiter=" ",unpack=False)
# learning 20
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.57610464176e9scores.txt",delimiter=" ",unpack=False)
# learning 30
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576104659914e9scores.txt",delimiter=" ",unpack=False)
# learning 40
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576104705091e9scores.txt",delimiter=" ",unpack=False)
# learning 50
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch21.576104733685e9scores.txt",delimiter=" ",unpack=False)

# 10s/10
#contents = loadtxt("Output/A/PLSsolo064_38_2_RAF_EP_ENP_ch11.576011693453e9scores.txt",delimiter=" ",unpack=False)

# 10s/10 C TROOOOOOP BEAU
#contents = loadtxt("Output/A/PLSsolo022_3_4_EP_RAF_ENP1.576113786829e9scores.txt",delimiter=" ",unpack=False)

# 10s/10 c'est rigolo car 2D mais bon
#contents = loadtxt("Output/A/PLSsolo039_38_4_EP_RAF_ch11.576113811797e9scores.txt",delimiter=" ",unpack=False)

# 10s/10 grave bo
#contents = loadtxt("Output/A/PLSsolo022_3_4_EP_RAF_ENP1.576118955469e9scores.txt",delimiter=" ",unpack=False)
# 10s/10 pas ouf trop gros
#contents = loadtxt("Output/A/PLSsolo024_38_3_EP_ENP_RAF1.576123961709e9scores.txt",delimiter=" ",unpack=False)
# 10s/10 pas ouf trop gros
#contents = loadtxt("Output/A/PLSsolo024_38_5_EP_ENP_RAF1.576137213844e9scores.txt",delimiter=" ",unpack=False)

# 10s/10 grave bo
#contents = loadtxt("Output/A/PLSsolo022_3_4_EP_RAF_ENP1.576118955469e9scores.txt",delimiter=" ",unpack=False)
# 10s/10 pas ouf trop gros
#contents = loadtxt("Output/A/genetic&PLS_scroreInNDTRee_064_38_2_RAF_EP_ENP_ch2.csv",delimiter=" ",unpack=False)
# 10s/10 le 2d mais pas ouf
#contents = loadtxt("Output/A/genetic&PLS_039_38_4_EP_RAF_ch1scores.txt",delimiter=" ",unpack=False)




#truc moche 1.0
#contents = loadtxt("Output/PLS/A/064_38_2_EP_RAF_ENP_ch2nb31scores.txt",delimiter=" ",unpack=False)
#truc moche 1.0
#contents = loadtxt("Output/PLS/A/064_38_2_EP_RAF_ENP_ch2nb72scores.txt",delimiter=" ",unpack=False)
#truc moche 1.0
#contents = loadtxt("Output/PLS/A/064_38_2_EP_RAF_ENP_ch2nb87scores.txt",delimiter=" ",unpack=False)
#truc moche 2.0
#contents = loadtxt("Output/PLS/A/064_38_2_RAF_EP_ENP_ch1nb186scores.txt",delimiter=" ",unpack=False)

#truc moche 0.0
#contents = loadtxt("Output/PLS/A/022_3_4_EP_RAF_ENPnb26scores.txt",delimiter=" ",unpack=False)

#truc 1
#contents = loadtxt("Output/A/genetic&PLS_scrore_064_38_2_RAF_EP_ENP_ch2.csv",delimiter=" ",unpack=False)
#truc pop trop cheum
#contents = loadtxt("Output/A/genetic_scrore_064_38_2_RAF_EP_ENP_ch2.csv",delimiter=" ",unpack=False)
#truc NDtree mieux ^^
#contents = loadtxt("Output/A/geneticNDTree_scrore_064_38_2_RAF_EP_ENP_ch2.csv",delimiter=" ",unpack=False)


fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
fig.suptitle("9")
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
