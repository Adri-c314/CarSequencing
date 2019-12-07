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
using Random
Random.seed!(10)

global length_windows = 1
global path = "../../Output/"
global surLinux = true



# Fonction main
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param temps_max : temps max pour un tuple (milliseconde)
function main(ir::Array{Tuple{String,String},1} = [("X", "028_CH2_EP_ENP_RAF_S51_J1")],  verbose::Bool = true, txtoutput::Bool = true, temps_max::Float64 = 1.0)
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
            txt = string(txt, "\n", tmp, "\n\n===================================================\n")
            for j in 1:length(score)
                txt = string(txt, "Valeur sur l'objectif ", j, " : ", score[j], "\n")
            end
            txt = string(txt,"===================================================\n\n")
            ecriture(seqToCSV(sol), pathOS(string(path, i[1], "/", "lexico_", i[2],".csv"), surLinux))
            ecriture(txt, pathOS(string(path, i[1], "/", "lexico_", i[2],".txt"), surLinux))
        end
        if verbose
            println(string("==================================================="))
            for j in 1:length(score)
                println(string("Valeur sur l'objectif ", j, " : ", score[j]))
            end
            println(string("===================================================\n\n"))
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
function mainGenetic(ir::Array{Tuple{String,String},1} = [("A", "022_3_4_EP_RAF_ENP")], nbSol::Int=50, temps_init::Float64 = 10., temps_phase1::Float64 = 10., temps_phaseAutres::Float64 = 10., temps_popNonElite::Float64 = 3., temps_global::Float64 = 300., temps_mutation::Float64 = 0.1, verbose::Bool = true, txtoutput::Bool = true)
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
        txt, population = genetic(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, verbose, txtoutput)

        # Gestion affichage :
        if txtoutput
            # TODO : gerer un peu d'output serait cool
        end
        if verbose
            # TODO : gerer un peu d'affichage serait cool
        end
    end
end



# Fonction main pour la PLS utilisant l'algorithm genetique generate
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param nbSol : la taille de la population
# @param temps_init : le temps alloué a la création de la solution initiale commune
# @param temps_phase1 : Le temps alloué à la premiere phase d'amélioration pour les solutions elites
# @param temps_phaseAutres : Le temps alloué aux autres phases d'amélioration pour les solutions elites
# @param temps_popNonElite : Le temps alloué à tout le processus d'amélioration pour les solutions non élites
# @param temps_global : Le temps alloué à tout l'algo genetique apres generation de la population de depart
# @param temps_mutation : Le temps alloué à une unique mutation
# @param temps_max : Le temps pour toute la PLS
# @param temps_1_moov : Le temps associé à un unique mouvement (proportion de temps_max)
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
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
        if txtoutput
            txt = string(
                "===================================================\n",
                "Etude de l'instance : ", i[1], "\n",
                "Reference du dossier : ", i[2], "\n",
                "A la date du : ", Dates.now(), "\n",
                "===================================================\n\n"
            )
        end

        # Lecture du fichier csv
        datas = lectureCSV(i[1], i[2])

        # Creation d'une population initiale grace
        solutions, inst = generate(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, verbose)

        # Création d'un NDtree
        NDtree = Sommet()

        # Ajout dans le NDTree les solution de la pop initiale valide
        nb_y_efficasses = 0
        for y in solutions
            maj!(NDtree, convert_genetic_PLS(y)) ? nb_y_efficasses += 1 : nothing
        end

        # Realisation de la PLS sur l'arbre :
        txt2 = PLS!(NDtree, inst, temps_global, temps_moove, verbose)

        # Affichage :
        plot_pareto(NDtree, file_name =  "PLS_" * string(temps_max) * "_s_" * inst.name, verbose = verbose)
        CSV_pareto(NDtree, file_name = "PLS_" * string(temps_max) * "_s_" * inst.name, verbose = verbose)

        if verbose
            println("Hypervolume de l'instance ", ir, " : ", hypervolume(NDtree))
        end
        if txtoutput
            txt = string(txt, txt2)
            # Ecriture du fichier Output

        end
    end
end



# Fonction mainTestPLS
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param temps_max : temps max pour un tuple (milliseconde)
function mainTestPLS(ir::Array{Tuple{String,String},1} = [("A", "025_38_1_EP_ENP_RAF")],  verbose::Bool = true, txtoutput::Bool = true)
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

<<<<<<< HEAD
        # Lecture du fichier csv
        datas = lectureCSV(i[1], i[2])

        # Lancement du NDtree
        @time score, sol, tmp = IniNDtree(datas, verbose, txtoutput)

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
        end

=======
            # Lecture du fichier csv
            datas = lectureCSV(i[1], i[2])
            path = "..\\..\\output\\"
            # Lancement de la VFLS
            @time score = IniNDtree(datas, verbose, txtoutput)
            println(score )
            println("FIN")
            path = "../../Output/PLS/"
            txt = ""
            txt = string(txt, scoreToCSV(score))
            ecriture(txt, string(path,i[1],"/",i[2],"nb",size(score)[1],".txt"))
            #writedlm(string(path,i[1],"_",i[2],".txt"), score)
    end

end



function mainTest()
    i  =("A", "022_3_4_RAF_EP_ENP")
    ii =("A", "022_3_4_EP_RAF_ENP")
    datas1 = lectureCSV(i[1], i[2])
    datas2 = lectureCSV(ii[1], ii[2])
    sequence_meilleure1,sequence_avant1, score_init1, tab_violation1 , ratio_option, Hprio, obj, pbl1 = compute_initial_sequence(datas1)
    sequence_meilleure2,sequence_avant2, score_init2, tab_violation2 , ratio_option, Hprio, obj, pbl2 = compute_initial_sequence(datas2)
    tmpi=1
    for car in sequence_meilleure1
        nook = false
        for car2 in sequence_meilleure2
            if car[2]==car2[2] && car[3]==car2[3]&& car[4]==car2[4]&& car[5]==car2[5]&& car[6]==car2[6]&& car[7]==car2[7]&& car[8]==car2[8]&& car[9]==car2[9]&& car[10]==car2[10]&& car[11]==car2[11]

                nook = true
                println("ok : ",tmpi)
                tmpi+=1
                break
            end
        end
        if !nook
        else
            println(car)
        end
    end
    println(tmpi)
end
