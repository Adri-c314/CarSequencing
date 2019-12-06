# Fichier contenant toutes les fonction associées à la génération de la population de depart
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1



# Fonction qui permet de generer l'ensemble de la population de depart
# @param datas : Le jeux de données lu
# @param nbSol : la taille de la population
# @param temps_init : le temps alloué a la création de la solution initiale commune
# @param temps_phase1 : Le temps alloué à la premiere phase d'amélioration pour les solutions elites
# @param temps_phaseAutres : Le temps alloué aux autres phases d'amélioration pour les solutions elites
# @param temps_popNonElite : Le temps alloué à tout le processus d'amélioration pour les solutions non élites
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @return ::Array{Array{Array{Array{Int,1},1},1},1} : La population initial
# return[1:nbSol] : chaque indice est une solution
# return[x][1] : Array{Array{Int,1},1} la sequence x
# return[x][2] : Array{Array{Int,1},1} le tab violation associé à la sequence x
# return[x][3][1] : Array{Int,1} le score sur les 3 obj
# @return ::Instance : l'instance de pb étudié cf fichier instance.jl
function generate(datas::NTuple{4,DataFrame}, nbSol::Int, temps_init::Float64, temps_phase1::Float64, temps_phaseAutres::Float64, temps_popNonElite::Float64, verbose::Bool=true, txtoutput::Bool=true)
    # Initialisation de la population
    population = Array{Array{Array{Array{Int,1},1},1},1}()

    # création de la sequence initial commune
    sequence_meilleure, sequence_j_avant, score_meilleur, tab_violation, ratio, Hprio, obj, pbl = initGenerate(datas, temps_init, verbose, txtoutput)
    inst = Instance(sequence_j_avant, ratio, Hprio, obj, pbl)
    sz = size(sequence_meilleure)[1]

    if verbose
        println("1) Information sur les données :")
        println("   ---------------------------")
        println("Nombre d'options prioritaires : ", Hprio)
        println("PAINT_BATCH_LIMIT : ", pbl)
        println("Nombre de vehicules : ", sz)
        println("\n\n\n")
    end

    if verbose
        println("2) Creation de la population initiale :")
        println("   ----------------------------------")
        println("Taille de la population :", nbSol)
        println("Budjet de calcule pour la phase initiale commune : ", temps_init, " secondes")
        println("Budjet de calcule pour chacune des 3 phase 1 : ", temps_phase1, " secondes")
        println("Budjet de calcule pour chacune des 6 phase suivantes : ", temps_phaseAutres, " secondes")
        println("Budjet de calcule pour chacune des ", nbSol-6, " solutions non elites : ", temps_popNonElite, " secondes")
        println("\n\n\n")
    end



    # Création des nbSol
    for i in 7:nbSol
        # Création de l'odre des obj pour cette instance :
        obj = shuffle(MersenneTwister(1234), Vector(1:3))

        # Ajout de l'elmt dans la pop
        push!(population, VFLS_genetic(sequence_meilleure, tab_violation, score_meilleur, obj, inst, temps_popNonElite))
    end

    return population, inst
end



# Fonction qui permet de générer la solution initiale (à l'origine de toutes les suivantes)
# @param datas : Le jeux de données lu
# @param temps_max : temps max pour un tuple (milliseconde)
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @return ::Array{Array{Int,1},1} : la sequence apres toute l'initialisation
# @return ::Array{Int,1} : Le score courant
# @return ::Array{Array{Int,1},1} : tab violation
# @return ::Array{Array{Int,1},1} : ratio_option le tableau des options
# @return ::Int : Hprio le nombre d'options prioritaires
# @return ::Array{Int,1} : le tableau des objectifs
# @return ::Int : PAINT_BATCH_LIMIT
function initGenerate(datas::NTuple{4,DataFrame}, temps_max::Float64 = 1.0, verbose::Bool=true, txtoutput::Bool=true)
        sequence_meilleure, sequence_j_avant, score_meilleur, tab_violation, prio, Hprio, obj, pbl = compute_initial_sequence(datas)
        # TODO : Amelioration de cette solution initiale ?
        return sequence_meilleure, sequence_j_avant, score_meilleur, tab_violation, prio, Hprio, obj, pbl
end



# Fonction qui réalise une fonction similaire à la phase 1 initiale suivant EP
# @param temps_phase1
function ameliorationEP(temps_phase1::Float64)

end



# Fonction qui réalise une fonction similaire à la phase 1 initiale suivant RAF
# @param temps_phase1
function ameliorationRAF(temps_phase1::Float64)

end
