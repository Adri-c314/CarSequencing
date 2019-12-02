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



# Fonction qui permet de dessider de l'insertion ou non d'un enfant dans la population
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param enfant : l'enfant générer
# @modify population : insere potentiellement l'enfant dans la pop
function insertionPotentielle!(population::Array{Array{Array{Array{Int,1},1},1},1}, enfant::Array{Array{Array{Int,1},1},1})
    ordre = shuffle(MersenneTwister(1234), Vector(1:length(population)))

    i = 1
    inserer = false
    while (i <= length(ordre)) && !inserer
        if domineFortement(population[ordre[i]], enfant)
            population[ordre[i]] = enfant
            inserer = true
        end
        i += 1
    end

    if !inserer
        i = 1
        while (i <= length(ordre)) && !inserer
            if domineClassique(population[ordre[i]], enfant)
                population[ordre[i]] = enfant
                inserer = true
            end
            i += 1
        end
    end

    # Si il domine pas il n'est pas nécessairement à jeter donc j'en fais quoi ?
    if !inserer
        #println("on ne l'a pas gardé !")
    end

    return nothing
end



# Fonction qui permet de verifier si l'elmt qu'on souhaite inserer domine fortement un elmt donné
# @param inPop : l'element dans la population
# @param insere : l'element auquel on veut comparer
# @return ::Bool : true si inPop est fortement dominé
function domineFortement(inPop::Array{Array{Array{Int,1},1},1}, insere::Array{Array{Array{Int,1},1},1})
    domination = true
    forte = false
    for i in 1:length(inPop[3][1])
        domination &= inPop[3][1][i] >= insere[3][1][i]
        forte |= inPop[3][1][i] > insere[3][1][i]
    end
    return  domination && forte
end



# Fonction qui permet de verifier si l'elmt qu'on souhaite inserer domine fortement un elmt donné
# @param inPop : l'element dans la population
# @param insere : l'element auquel on veut comparer
# @return ::Bool : true si inPop est dominé
function domineClassique(inPop::Array{Array{Array{Int,1},1},1}, insere::Array{Array{Array{Int,1},1},1})
    domination = true
    for i in 1:length(inPop[3][1])
        domination &= inPop[3][1][i] >= insere[3][1][i]
    end
    return  domination
end



# Fonction qui choisi l'indice suivant un aléatoire pondéré par les scores
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param choix : l'obj focus
# @param priveDe : La valeur du pere si elle existe
# @return ::int : Un indice :)
function choixIndice(population::Array{Array{Array{Array{Int,1},1},1},1}, choix::Int=1, priveDe::Int=0)
    interval = Array{Float64,1}(undef, length(population))
    interval[1] = 1/(population[1][3][1][choix]+1)

    for i in 2:length(population)
        if i != priveDe
            interval[i] = interval[i-1] + 1/(population[i][3][1][choix]+1)
        else
            interval[i] = interval[i-1]
        end
    end
    tmpInterval = rand()*interval[length(population)]
    rtn = indiceInInterval(interval, tmpInterval)
    if rtn == priveDe
        rtn += 1
    end
    return rtn
end



# Fonction qui cherche l'indice d'une valeur
# La recherche pu la m**** possible de faire une dicotomie mais pas le temps
# @param interval : l'interval
# @param tmpInterval : la val alea
# @return l'indice dans la population
function indiceInInterval(interval::Array{Float64,1}, tmpInterval::Float64)
    for i in 1:length(interval)
        if interval[i] >= tmpInterval
            return i
        end
    end
    return 1
end
