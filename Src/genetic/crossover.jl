# Fichier contenant toutes les fonction associées au crossover entre plusieurs sequence
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1



# Fonction qui realise le crossover entre deux sequences
# @param papa : l'indice du papa dans la population
# @param maman : l'indice de la maman dans la population
# @param population : la population globale
# @param obj : l'objectif in (:pbl!, :hprio!, :lprio!) suivant l'obj qu'on focus
# @return ::Array{Array{Array{Int,1},1},1} : l'enfant générer
function crossover(papa::Int, maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1}, obj::Symbol)
    # TODO : realiser le crossover

    # J'ai mis return population[papa] pour respecter le typage mais c'est provisoir
    return population[papa]
end
