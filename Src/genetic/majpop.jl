# Fichier contenant toutes les fonctions associées à l'algorithm génétique dans sa partie de mise à jour de la population
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 30/11/2019
# @version 1


# Fonction qui selectionne l'obj a focus ainsi que l'indice du pere et de la mere
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @return ::Int : l'indice du pere dans la population tq on le recupere avec population[papa]
# @return ::Int : l'indice de la mere dans la population tq on le recupere avec population[maman]
# @return ::Symbol : (:pbl!, :hprio!, :lprio!) suivant l'obj qu'on focus
function selection(population::Array{Array{Array{Array{Int,1},1},1},1})
    # Les differents objectifs qu'on peut focus :
    obj = (:pbl!, :hprio!, :lprio!)

    # Choix de l'objectif et des parents associés :
    choix = rand(1:3)
    totalscore = 0
    papa = choixIndice(population, choix)
    maman = choixIndice(population, choix, papa)

    return papa, maman, obj[choix]
end



# Fonction qui choisi l'indice suivant un aléatoire pondéré par les scores
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param choix : l'obj focus
# @param priveDe : La valeur du pere si elle existe
# @return ::int : Un indice :)
function choixIndice(population::Array{Array{Array{Array{Int,1},1},1},1}, choix::Int=1, priveDe::Int=0)
    interval = Array{Int,1}(undef, length(population))
    interval[1] = population[1][3][1][choix]
    for i in 2:length(population)
        if i != priveDe
            interval[i] = interval[i-1] + population[i][3][1][choix]
        else
            interval[i] = interval[i-1]
        end
    end
    tmpInterval = rand(1:interval[length(population)])
    rtn = indiceInInterval(interval, tmpInterval)
    return rtn
end



# Fonction qui cherche l'indice d'une valeur
# La recherche pu la m**** possible de faire une dicotomie mais pas le temps
# @param interval : l'interval
# @param tmpInterval : la val alea
# @return l'indice dans la population
function indiceInInterval(interval::Array{Int,1}, tmpInterval::Int)
    for i in 1:length(interval)
        if interval[i] >= tmpInterval
            return i
        end
    end
    return 1
end
