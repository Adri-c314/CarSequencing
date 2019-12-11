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

    return inserer
end



# Fonction qui permet de dessider de l'insertion ou non d'un enfant dans la population
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param enfants : la pop d'enfants générer
# @modify population : creer une nouvelle pop a partir des enfants+parents non dominés
function insertionPotentielleEnfants!(population::Array{Array{Array{Array{Int,1},1},1},1}, enfants::Array{Array{Array{Array{Int,1},1},1},1})
    nn = length(population)
    n = nn + length(enfants)

    append!(enfants, deepcopy(population))

    # Gestion des enfants conservés
    indkeep = Array{Int,1}()
    while length(indkeep)<=nn
        ordre = getOrdre(n, indkeep)

        i = 1
        while i<=length(ordre) && length(indkeep)<=nn
            if nonDomineInPop(enfants, ordre[i], ordre)
                push!(indkeep, deepcopy(ordre[i]))
            end
            i += 1
        end
    end

    population = Array{Array{Array{Array{Int,1},1},1},1}()
    for i in indkeep
        push!(population, deepcopy(enfants[i]))
    end
end



# Fonction qui permet de dessider de l'insertion ou non d'un enfant dans la population
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param enfants : la pop d'enfants générer
# @param nbEnfants : Le cota d'enfants que l'on conserve à chaque fois
# @modify population : insere nb enfant dans la pop dans la pop
function insertionPotentielleEnfants!(population::Array{Array{Array{Array{Int,1},1},1},1}, enfants::Array{Array{Array{Array{Int,1},1},1},1}, nbEnfants::Int)
    if nbEnfants > 0
        n = length(population)

        # Gestion des enfants conservés
        indkeepEnfants = Array{Int,1}()
        while length(indkeepEnfants)<=nbEnfants
            ordre = getOrdre(n, indkeepEnfants)

            i = 1
            while i<=length(ordre) && length(indkeepEnfants)<=nbEnfants
                if nonDomineInPop(enfants, ordre[i], ordre)
                    push!(indkeepEnfants, deepcopy(ordre[i]))
                end
                i += 1
            end
        end

        # Gestion des parents gardés
        popkeep = Array{Array{Array{Array{Int,1},1},1},1}()
        indkeep = Array{Int,1}()
        while length(popkeep)<=n-nbEnfants
            ordre = getOrdre(n, indkeep)

            i = 1
            while i<=length(ordre) && length(popkeep)<=n-nbEnfants
                if nonDomineInPop(population, ordre[i], ordre)
                    push!(popkeep, deepcopy(population[ordre[i]])) # TODO : Doute sur la nécessité de cette deepcopy
                    push!(indkeep, deepcopy(ordre[i]))
                end
                i += 1
            end
        end

        population = Array{Array{Array{Array{Int,1},1},1},1}()
        append!(population, deepcopy(popkeep))
        for i in indkeepEnfants
            push!(population, deepcopy(enfants[i]))
        end

    else
        insertionPotentielleEnfants!(population, enfants)
    end
end



# Fonction qui permet de dessider de l'insertion ou non d'un enfant dans la population
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param enfants : la pop d'enfants générer
# @param NDTree : le nd tree qu'on met potentiellement à jour
# @modify NDTree : on ajoute dans certains cas
# @modify population : creer une nouvelle pop a partir des enfants+parents non dominés
function insertionPotentielleEnfants!NDTree(population::Array{Array{Array{Array{Int,1},1},1},1}, enfants::Array{Array{Array{Array{Int,1},1},1},1}, NDTree::Sommet)
    nn = length(population)
    n = nn + length(enfants)

    append!(enfants, deepcopy(population))

    # Gestion des enfants conservés
    indkeep = Array{Int,1}()
    while length(indkeep)<=nn
        ordre = getOrdre(n, indkeep)

        i = 1
        while i<=length(ordre) && length(indkeep)<=nn
            if nonDomineInPop(enfants, ordre[i], ordre)
                push!(indkeep, deepcopy(ordre[i]))
            end
            i += 1
        end
    end

    cpt = 0
    population = Array{Array{Array{Array{Int,1},1},1},1}()
    for i in indkeep
        if i <= nn
            maj!(NDTree, (enfants[i][1], enfants[i][3][1], enfants[i][2]))
            cpt += 1
        end
        push!(population, deepcopy(enfants[i]))
    end
    return cpt
end



# Fonction qui permet de dessider de l'insertion ou non d'un enfant dans la population
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param enfants : la pop d'enfants générer
# @param nbEnfants : Le cota d'enfants que l'on conserve à chaque fois
# @param NDTree : le nd tree qu'on met potentiellement à jour
# @modify NDTree : on ajoute dans certains cas
# @modify population : insere nb enfant dans la pop dans la pop
function insertionPotentielleEnfants!NDTree(population::Array{Array{Array{Array{Int,1},1},1},1}, enfants::Array{Array{Array{Array{Int,1},1},1},1}, nbEnfants::Int, NDTree::Sommet)
    if nbEnfants > 0
        n = length(population)

        # Gestion des enfants conservés
        indkeepEnfants = Array{Int,1}()
        while length(indkeepEnfants)<=nbEnfants
            ordre = getOrdre(n, indkeepEnfants)

            i = 1
            while i<=length(ordre) && length(indkeepEnfants)<=nbEnfants
                if nonDomineInPop(enfants, ordre[i], ordre)
                    push!(indkeepEnfants, deepcopy(ordre[i]))
                end
                i += 1
            end
        end

        # Gestion des parents gardés
        popkeep = Array{Array{Array{Array{Int,1},1},1},1}()
        indkeep = Array{Int,1}()
        while length(popkeep)<=n-nbEnfants
            ordre = getOrdre(n, indkeep)

            i = 1
            while i<=length(ordre) && length(popkeep)<=n-nbEnfants
                if nonDomineInPop(population, ordre[i], ordre)
                    push!(popkeep, deepcopy(population[ordre[i]])) # TODO : Doute sur la nécessité de cette deepcopy
                    push!(indkeep, deepcopy(ordre[i]))
                end
                i += 1
            end
        end

        population = Array{Array{Array{Array{Int,1},1},1},1}()
        append!(population, deepcopy(popkeep))
        for i in indkeepEnfants
            maj!(NDTree, (enfants[i][1], enfants[i][3][1], enfants[i][2]))
            push!(population, deepcopy(enfants[i]))
        end

        return length(indkeepEnfants)
    else
        return insertionPotentielleEnfants!NDTree(population, enfants, NDTree)
    end
end



# Fonction qui permet de recuperer les element encore possiblement insérables dans la nouvelle population
# @param taillePop : la taille de tous les indices
# @param indkeep : Les indices de ceux deja selectionnés
# @return ::Array{Int, 1} : les indices mélangés
function getOrdre(taillePop::Int, indkeep::Array{Int, 1})
    ens = Vector(1:taillePop)
    tmp = 0
    indkeep = sort(indkeep)
    for b in indkeep
        deleteat!(ens, b - tmp)
        tmp += 1
    end
    return shuffle(MersenneTwister(1234), ens)
end



# Fonction qui verifie si un element est non dominé dans la population
# @param pop : la population complète
# @param indice : l'indice de celui dont on veut test si il est non dominé
# @param ordre : l'ordre des indices dans la pop (permet aussi de retirer ceux que l'on souhaite)
# @return ::Bool : true si il est non dominé
function nonDomineInPop(pop::Array{Array{Array{Array{Int,1},1},1},1}, indice::Int, ordre::Array{Int,1})
    dominer = false
    i = 1

    while !dominer && i<=length(ordre)
        if domineFortement(pop[indice], pop[ordre[i]])
            dominer = true
        end
        i += 1
    end

    if dominer
        return false
    end

    return true
end



# Fonction qui permet de dessider de l'insertion ou non d'un enfant dans la population
# @param population : la population comme elle est definie plus précisement dans generate.jl
# @param enfant : l'enfant générer
# @param NDTree : le nd tree qu'on met potentiellement à jour
# @modify NDTree : on ajoute dans certains cas
# @modify population : insere potentiellement l'enfant dans la pop
function insertionPotentielle!NDTree(population::Array{Array{Array{Array{Int,1},1},1},1}, enfant::Array{Array{Array{Int,1},1},1}, NDTree::Sommet)


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

    # Ajout dans l'arbre
    if inserer
        maj!(NDTree, (enfant[1], enfant[3][1], enfant[2]))
    end

    return inserer
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
