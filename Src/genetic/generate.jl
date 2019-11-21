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
function generate(datas::NTuple{4,DataFrame}, nbSol::Int, temps_init::Float64 = 120, temps_phase1::Float64 = 300, temps_phaseAutres::Float64 = 300, temps_popNonElite::Float64 = 30, verbose::Bool=true, txtoutput::Bool=true)
    # création de la sequence initial commune
    sequence_meilleure, score_init, tab_violation, ratio_option, Hprio, obj, pbl = initGenerate(datas, temps_init, verbose, txtoutput)

    # Realisation des amélioration selon EP :
    ameliorationEP(temps_phase1)

    # Réalisation des amelioration selon RAF :
    ameliorationRAF(temps_phase1)

    # Realisation des amelioration selon ENP :
    ameliorationENP(temps_phase1)


    return nothing # TODO : Renvoyer les nbSol sequences avec les données associées nécessaires
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
        sequence_meilleure, score_init, tab_violation, ratio_option, Hprio, obj, pbl = compute_initial_sequence(datas)
        # TODO : Amelioration de cette solution initiale ?
        return sequence_meilleure, score_init, tab_violation, ratio_option, Hprio, obj, pbl
end



# Fonction qui réalise une fonction similaire à la phase 1 initiale suivant EP
# @param temps_phase1
function ameliorationEP(temps_phase1::Float64 = 300)

end



# Fonction qui réalise une fonction similaire à la phase 1 initiale suivant RAF
# @param temps_phase1
function ameliorationRAF(temps_phase1::Float64 = 300)

end
