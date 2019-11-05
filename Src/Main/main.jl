# Fichier contenant toutes les fonctions d'initialisation de données.
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 3

include("../Util/includes.jl")
using Dates


# Fonction main
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param temps_max : temps max pour un tuple (milliseconde)
function main(ir::Array{Tuple{String,String},1} = [("A", "022_3_4_EP_RAF_ENP"),("A", "022_3_4_RAF_EP_ENP"),("A", "024_38_3_EP_RAF_ENP"),("A", "024_38_3_RAF_EP_ENP"),("A", "024_38_5_EP_RAF_ENP"),("A", "024_38_5_RAF_EP_ENP")],  verbose::Bool = true, txtoutput::Bool = true, temps_max::Float64 = 600.0)
    for i in ir
        # Gestion affichage :
        if txtoutput
            txt = string(
                "===================================================\n",
                "Etude de l'instance : ", i[1], "\n",
                "Reference du dossier : ", i[2], "\n",
                "A la date du : ", Dates.now(), "\n",
                "===================================================\n\n"
            )
        end
        if verbose
            println(string(
                "===================================================\n",
                "Etude de l'instance : ", i[1], "\n",
                "Reference du dossier : ", i[2], "\n",
                "A la date du : ", Dates.now(), "\n",
                "===================================================\n\n"
            ))
        end

        # Lecture du fichier csv
        datas = lectureCSV(i[1], i[2])

        # Lancement de la VFLS
        score, sol, tmp = VFLS(datas, temps_max, verbose, txtoutput)

        # Gestion affichage :
        if txtoutput
            txt = string(txt, "\n", tmp, "===================================================\n")
            for j in 1:length(score)
                txt = string(txt, "Valeur sur l'objectif ", j, " : ", score[j], "\n")
            end
            txt = string(txt,"===================================================\n\n")
            txt = string(txt, sol)
        end
        if verbose
            println(string("==================================================="))
            for j in 1:length(score)
                println(string("Valeur sur l'objectif ", j, " : ", score[j]))
            end
            println(string("===================================================\n\n"))
            #println(sol)
        end
    end
end
