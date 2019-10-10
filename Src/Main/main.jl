include("../Util/includes.jl")
<<<<<<< HEAD
using Dates

# Gestion de l'instance :
instance = "A"
reference = "022_3_4_EP_RAF_ENP"
datas = lectureCSV(instance, reference)

# Initialisation de la variable txt du fichier output :
txt = string(
    "===================================================\n",
    "Etude de l'instance : ", instance, "\n",
    "Reference du dossier : ", reference, "\n",
    "A la date du : ", Dates.now(), "\n",
    "===================================================\n\n"
)

# Initialisation des données :
vehicles = datas[1]
oo = datas[2] #optimization_objectives
pbl = datas[3] #paint_batch_limi
ratio = datas[4]






# Ecriture dans le fichier output
ecriture(txt, string("../../Output/", Dates.now(), ".txt"))
