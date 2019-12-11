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
        datas = lectureCSV(i[1], i[2], surLinux)

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
function mainGenetic(ir::Array{Tuple{String,String},1} = [("A", "064_38_2_RAF_EP_ENP_ch2")], nbSol::Int=50, temps_init::Float64 = 300., temps_phase1::Float64 = 300., temps_phaseAutres::Float64 = 300., temps_popNonElite::Float64 = 10., temps_global::Float64 = 600., temps_mutation::Float64 = 0.1, mutation2::Bool = true, enfants::Bool = true, cota::Int=0, verbose::Bool = true, txtoutput::Bool = true, csvscore::Bool = true, csvsequences::Bool = true)
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
        datas = lectureCSV(i[1], i[2], surLinux)

        # Lancement de la VFLS
        if enfants
            txt, population = geneticEnfants(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, mutation2, 0, verbose, txtoutput)
        else
            txt, population = genetic(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, mutation2, verbose, txtoutput)
        end

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
function mainGeneticPLS(ir::Array{Tuple{String,String},1} = [("A", "064_38_2_RAF_EP_ENP_ch2")], nbSol::Int=50, temps_init::Float64 = 300., temps_phase1::Float64 = 300., temps_phaseAutres::Float64 = 200., temps_popNonElite::Float64 = 10., temps_global::Float64 = 600., temps_mutation::Float64 = 0.02, mutation2::Bool = true, enfants::Bool = true, cota::Int=0, verbose::Bool = true, txtoutput::Bool = true, csvscore::Bool = true, csvsequences::Bool = true)
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
        datas = lectureCSV(i[1], i[2], surLinux)

        # Creation du NDTree pour le genetic
        NDTree = Sommet()

        if enfants
            txt, population = geneticEnfants!(datas, NDTree, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, mutation2, 0, verbose, txtoutput)
        else
            txt, population = genetic!(datas, NDTree, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, temps_global, temps_mutation, mutation2, verbose, txtoutput)
        end

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
        solutions = get_solutions(NDTree)
        if csvscore
            tmp = ""
            for ii in 1:length(solutions)
                tmp = string(tmp, solutions[ii][2][1]," ", solutions[ii][2][2]," ", solutions[ii][2][3],"\n")
            end
            ecriture(tmp, pathOS(string(path, i[1], "/", "genetic&PLS_scrore_", i[2],".csv"), surLinux))
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




# Fonction mainTestPLS
# @param ir : L'ensemble des noms d'instances avec la reference a etudié
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @param temps_max : temps max pour un tuple (milliseconde)
function mainTestPLS(ir::Array{Tuple{String,String},1} = [("A", "064_38_2_RAF_EP_ENP_ch2")], temps_all::Float64 = 5000., temps_max::Float64 = 600., temps_max2::Float64 = 50., temps_max3::Float64 = 2., temps_max4::Float64 = 10., verbose::Bool = true, txtoutput::Bool = true, csvscore::Bool = true, csvpopulation::Bool = true)
    temps4 = [3.,5.,10.,20.]
    for j in 1:4
        temps_max4 = temps4[j]
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
            datas = lectureCSV(i[1], i[2], surLinux)

            # Creation d'un NDTree gloablisé
            NDtree = Sommet()

            # Lancement de la VFLS
            @time score, szscore, nadir, sollexico = IniNDtree(datas, NDtree, temps_all, temps_max, temps_max2, temps_max3, temps_max4, verbose, txtoutput)

            # Gestion de l'affichage :
            if verbose
                println("Score : ", score)
                println("\n\n\n")
                println("===================================================")
                println("Ecriture des pts .txt : ", txtoutput)
                println("Ecriture des scores .txt : ", csvscore)
                println("Ecriture de la population .csv : ", csvpopulation)
                println("===================================================")
                println("\n\n\n")
            end
            ttt = time()
            if csvscore
                ecriture(scoreToCSV(score), pathOS(string(path,i[1],"/PLSsolo",i[2],ttt,"scores",".txt"), surLinux))
            end
            if txtoutput
                ecriture(string(temps_all, " ", temps_max, " ", temps_max2, " ", temps_max3, " ", temps_max4 ,allToCSV(nadir,szscore,sollexico)), pathOS(string(path,i[1],"/PLSsolo",i[2],ttt,"elements",".txt"), surLinux))
            end
            if csvpopulation
                solutions = get_solutions(NDtree)
                tmp = ""
                for ii in 1:length(solutions)
                    tmp = string(tmp, "\n", seqToCSV(solutions[ii][1]))
                end
                ecriture(tmp, pathOS(string(path, i[1], "/", "PLSsolo_seq_", i[2],".csv"), surLinux))
            end
        end
    end
end
