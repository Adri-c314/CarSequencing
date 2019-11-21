# Fichier contenant toutes les fonctions associées à l'algorithm génétique dans sa gloablité
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1



# Fonction qui réalise l'ensemble de l'algorithm génétique
# @param datas : Le jeux de données lu
# @param nbSol : la taille de la population
# @param temps_init : le temps alloué a la création de la solution initiale commune
# @param temps_phase1 : Le temps alloué à la premiere phase d'amélioration pour les solutions elites
# @param temps_phaseAutres : Le temps alloué aux autres phases d'amélioration pour les solutions elites
# @param temps_popNonElite : Le temps alloué à tout le processus d'amélioration pour les solutions non élites
# @param temps_global : Le temps alloué à tout l'algo genetique apres generation de la population de depart 
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
function genetic(datas::NTuple{4,DataFrame}, nbSol::Int, temps_init::Float64 = 120, temps_phase1::Float64 = 300, temps_phaseAutres::Float64 = 300, temps_popNonElite::Float64 = 30, temps_global::Float64 = 300, verbose::Bool=true, txtoutput::Bool=true)
    # Génération de la population de depart
    generate(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, verbose, txtoutput)

    while temps_global != 0 # Boucle infinie volontaire on reglera apres
        # selection prendre des elements de la pop ?

        # crossover

        # mutation

        # insertion dans la pop ?
    end
end
