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
using DelimitedFiles
global length_windows = 1

using Random
Random.seed!(10)
# Fonction main
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param temps_max : temps max pour un tuple (milliseconde)
function main(ir::Array{Tuple{String,String},1} = [("X", "022_RAF_EP_ENP_S49_J2")
("X", "023_EP_RAF_ENP_S49_J2")
("X", "024_EP_RAF_ENP_S49_J2")
("X", "025_EP_ENP_RAF_S49_J1")
("X", "028_CH1_EP_ENP_RAF_S50_J4")
("X", "028_CH2_EP_ENP_RAF_S51_J1")
("X", "029_EP_RAF_ENP_S49_J5")
("X", "034_VP_EP_RAF_ENP_S51_J1_J2_J3")
("X", "034_VU_EP_RAF_ENP_S51_J1_J2_J3")
("X", "035_CH1_RAF_EP_S50_J4")
("X", "035_CH2_RAF_EP_S50_J4")
("X", "039_CH1_EP_RAF_ENP_S49_J1")
("X", "039_CH3_EP_RAF_ENP_S49_J1")
("X", "048_CH1_EP_RAF_ENP_S50_J4")
("X", "048_CH2_EP_RAF_ENP_S49_J5")
("X", "064_CH1_EP_RAF_ENP_S49_J1")
("X", "064_CH2_EP_RAF_ENP_S49_J4")
("X", "655_CH1_EP_RAF_ENP_S51_J2_J3_J4")
("X", "655_CH2_EP_RAF_ENP_S52_J1_J2_S01_J1")],  verbose::Bool = true, txtoutput::Bool = true, temps_max::Float64 = 600.0)
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
            path = "..\\..\\output\\"
            # Lancement de la VFLS
            score, sol, tmp = VFLS(datas, temps_max, verbose, txtoutput)
            # Gestion affichage :
            if txtoutput
                txt = string(txt, "\n", tmp, "===================================================\n")
                for j in 1:length(score)
                    txt = string(txt, "Valeur sur l'objectif ", j, " : ", score[j], "\n")
                end
                txt = string(txt,"===================================================\n\n")
                txt = string(txt, seqToCSV(sol))
                writedlm(string(path,i[1],"_",i[2],".txt"), score)
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



# Fonction main pour l'algorithm genetique
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param nbSol : la taille de la population
# @param temps_init : le temps alloué a la création de la solution initiale commune
# @param temps_phase1 : Le temps alloué à la premiere phase d'amélioration pour les solutions elites
# @param temps_phaseAutres : Le temps alloué aux autres phases d'amélioration pour les solutions elites
# @param temps_popNonElite : Le temps alloué à tout le processus d'amélioration pour les solutions non élites
# @param temps_global : Le temps alloué à tout l'algo genetique apres generation de la population de depart
# @param temps_mutation : Le temps alloué à une unique mutation
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
function mainGenetic(ir::Array{Tuple{String,String},1} = [("A", "022_3_4_EP_RAF_ENP")], nbSol::Int=50, temps_init::Float64 = 120., temps_phase1::Float64 = 300., temps_phaseAutres::Float64 = 300., temps_popNonElite::Float64 = 3., temps_global::Float64 = 300., temps_mutation::Float64 = 0.1, verbose::Bool = true, txtoutput::Bool = true)
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
        genetic(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, verbose, txtoutput)

        # Gestion affichage :
        if txtoutput
            # TODO : gerer un peu d'output serait cool
        end
        if verbose
            # TODO : gerer un peu d'affichage serait cool
        end


    end
end


function mainPLS(ir::Array{Tuple{String,String},1} = [("A", "022_3_4_EP_RAF_ENP")], nbSol::Int=50, temps_init::Float64 = 1., temps_phase1::Float64 = 3., temps_phaseAutres::Float64 = 3., temps_popNonElite::Float64 = 3., temps_global::Float64 = 5., temps_mutation::Float64 = 0.1, temps_max::Float64 = 3., temps_moove::Float64 = 0.001, verbose::Bool = true, txtoutput::Bool = true)
    for i in ir
        if verbose
            println(string(
                "===================================================\n",
                "Etude de l'instance : ", i[1], "\n",
                "Reference du dossier : ", i[2], "\n",
                "A la date du : ", Dates.now(), "\n",
                "===================================================\n\n"
            ))
        end
        datas = lectureCSV(i[1], i[2])
        solutions, inst = generate(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, verbose)
        NDtree = Sommet()
        nb_y_efficasses = 0
        for y in solutions
            maj!(NDtree, convert_genetic_PLS(y)) ? nb_y_efficasses += 1 : nothing
        end
        PLS!(NDtree, inst, temps_global, temps_moove, verbose)
        plot_pareto(NDtree, file_name =  "PLS_" * string(temps_max) * "_s_" * inst.name, verbose = verbose)
        CSV_pareto(NDtree, file_name = "PLS_" * string(temps_max) * "_s_" * inst.name, verbose = verbose)
        println("Hypervolume de l'instance ", ir, " : " hypervolume(NDtree))
    end
end
