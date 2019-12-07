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
function main(ir::Array{Tuple{String,String},1} = [("A", "064_38_2_EP_RAF_ENP_ch2")],  verbose::Bool = true, txtoutput::Bool = true, temps_max::Float64 = 1.0)
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
# @param csvscore : Si l'on souhaite conserver les score de toute la pop dans un fichier .csv
# @param csvsequences : Si l'on souhaite conserver la sequence de toute la pop dans un fichier .csv
function mainGenetic(ir::Array{Tuple{String,String},1} = [("A", "022_3_4_EP_RAF_ENP")], nbSol::Int=50, temps_init::Float64 = 10., temps_phase1::Float64 = 10., temps_phaseAutres::Float64 = 10., temps_popNonElite::Float64 = 3., temps_global::Float64 = 300., temps_mutation::Float64 = 0.1, verbose::Bool = true, txtoutput::Bool = true, csvscore::Bool = true, csvsequences::Bool = true)
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
            ecriture(txt, pathOS(string(path, i[1], "/", "genetic", i[2],".txt"), surLinux))
        end
        if csvscore
            tmp = ""
            for ii in 1:length(population)
                tmp = string(tmp, scoreToCSV(population[ii][3]))
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic_scrore_", i[2],".csv"), surLinux))
        end
        if csvsequences
            tmp = ""
            for ii in 1:length(population)
                tmp = string(tmp, "\n", seqToCSV(population[ii][1]))
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic_seq_", i[2],".csv"), surLinux))
        end
        if verbose
            println("\n\n\n")
            println("===================================================")
            println("Ecriture des sequences .csv : ", csvsequences)
            println("Ecriture des scores .csv : ", csvscore)
            println("Ecriture des logs .txt : ", txtoutput)
            println("===================================================")
            println("\n\n\n")
        end
    end
end



# Fonction main pour l'algorithm genetique et qui permet de recuperer un NDTree
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param nbSol : la taille de la population
# @param temps_init : le temps alloué a la création de la solution initiale commune
# @param temps_phase1 : Le temps alloué à la premiere phase d'amélioration pour les solutions elites
# @param temps_phaseAutres : Le temps alloué aux autres phases d'amélioration pour les solutions elites
# @param temps_popNonElite : Le temps alloué à tout le processus d'amélioration pour les solutions non élites
# @param temps_global : Le temps alloué à tout l'algo genetique apres generation de la population de depart
# @param temps_mutation : Le temps alloué à une unique mutation
# @param temps_max : Le temps pour toute la PLS
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param csvscore : Si l'on souhaite conserver les score de toute la pop dans un fichier .csv
# @param csvsequences : Si l'on souhaite conserver la sequence de toute la pop dans un fichier .csv
function mainGeneticPLS(ir::Array{Tuple{String,String},1} = [("A", "022_3_4_EP_RAF_ENP")], nbSol::Int=50, temps_init::Float64 = 10., temps_phase1::Float64 = 10., temps_phaseAutres::Float64 = 10., temps_popNonElite::Float64 = 3., temps_global::Float64 = 300., temps_mutation::Float64 = 0.1, temps_max::Float64 = 1.0, verbose::Bool = true, txtoutput::Bool = true, csvscore::Bool = true, csvsequences::Bool = true)
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

        # Creation du NDTree pour le genetic
        NDTree = Sommet()

        # Lancement de la VFLS
        txt, population, inst = genetic!(datas, NDTree, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, verbose, txtoutput)

        # Gestion affichage :
        if csvscore
            tmp = ""
            for ii in 1:length(population)
                tmp = string(tmp, scoreToCSV(population[ii][3]))
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic_scrore_", i[2],".csv"), surLinux))
        end
        if csvsequences
            tmp = ""
            for ii in 1:length(population)
                tmp = string(tmp, "\n", seqToCSV(population[ii][1]))
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic_seq_", i[2],".csv"), surLinux))
        end
        if verbose
            println("\n\n\n")
            println("===================================================")
            println("Ecriture des sequences .csv : ", csvsequences)
            println("Ecriture des scores .csv : ", csvscore)
            println("===================================================")
            println("\n\n\n")
        end

        # TODO : Verifier que j'ai bien fait
        txt2 = PLS!(NDTree, inst, temps_max, temps_max/1000., verbose, txtoutput)

        # Gestion affichage :
        solutions = get_solutions(NDTree)
        if csvscore
            tmp = ""
            for ii in 1:length(solutions)
                tmp = string(tmp, scoreToCSV(population[ii][2]))
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic&PLS_scrore_", i[2],".csv"), surLinux))
        end
        if csvsequences
            tmp = ""
            for ii in 1:length(solutions)
                tmp = string(tmp, "\n", seqToCSV(solutions[ii][1]))
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic&PLS_seq_", i[2],".csv"), surLinux))
        end
        if verbose
            println("\n\n\n")
            println("===================================================")
            println("Ecriture des sequences .csv : ", csvsequences)
            println("Ecriture des scores .csv : ", csvscore)
            println("Ecriture des logs .txt : ", txtoutput)
            println("===================================================")
            println("\n\n\n")
        end

        # Sortie TXT à la toute fin
        if txtoutput
            ecriture(string(txt, txt2) , pathOS(string(path, i[1], "/", "geneticPLS", i[2],".txt"), surLinux))
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
function mainPLS(ir::Array{Tuple{String,String},1} = [("A", "064_38_2_EP_RAF_ENP_ch2")], nbSol::Int=50, temps_init::Float64 = 1., temps_phase1::Float64 = 3., temps_phaseAutres::Float64 = 3., temps_popNonElite::Float64 = 3., temps_global::Float64 = 5., temps_mutation::Float64 = 0.1, temps_max::Float64 = 3., temps_moove::Float64 = 0.001, verbose::Bool = true, txtoutput::Bool = true)
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
            ecriture(string(txt, txt2) , pathOS(string(path, i[1], "/", "PLS", i[2],".txt"), surLinux))
        end
    end
end



# Fonction mainTestPLS
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param temps_max : temps max pour un tuple (milliseconde)
function mainTestPLS(ir::Array{Tuple{String,String},1} = [("A", "064_38_2_EP_RAF_ENP_ch2")],  verbose::Bool = true, txtoutput::Bool = true)
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
    end
end
