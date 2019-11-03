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
function main(ir::Array{Tuple{String,String},1} = [("A", "039_38_4_RAF_EP_ch1"), ("A", "022_3_4_RAF_EP_ENP")],  verbose::Bool = true, txtoutput::Bool = true, temps_max::Float64 = 1000.0)
    #=
    ## Instance : les voitures avec [1]= leur place mais pas utlie en vrai
    ##            les voitures avec [2]= leurs couleurs
    ##            les voitures avec [3:3+Hprio]= leurs Hprio (ca serait pas plutot [3:3+Hprio-1] ?)
    ##            les voitures avec [3+Hprio:]= leurs Lprio
    ##                              [size()[1]-2] = le debut de leur sequence de couleur
    ##                              [size()[1]-1] = la fin de leur sequence de couleur
    ## Ratio x/y: Les ratio avec [1] = x
    ##            Les ratio avec [2] = y
    ## pbl      : Le paint batch limit
    ## obj      : Les obj des l'ordre
    ## Hprio    : le nombre de Hprio
    =#

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
        println(typeof(datas))
        # Lancement de la VFLS
        VFLS(datas)
        # Gestion affichage :
        if txtoutput
            txt = string(
                "fini mais faudrait mettre plus d'infos ici non ?\n"
            )
        end
        if verbose
            println(string(
                "fini mais faudrait mettre plus d'infos ici non ?\n"
            ))
        end
    end
end
