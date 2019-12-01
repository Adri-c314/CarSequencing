# NDtree, sert a stocker l'ensemble de Pareto
# Cas d'utilisation :
#
# 1) Instanciation :
# NDtree = Sommet()
#
# 2) Tentative d'insertion d'une nouvelle solution y::Tuple{Array{Array{Int32,1},1}, Array{Int32,1}}. Exemple : y = (sequence des vehilcules, valeurs des objectifs).
# maj!(NDtree, y) # Retourne un boolean qui dit si la solution est efficasse et a ete inseree.
#
# 3) Lecture de toutes les solutions inserees
# solutions = get_solutions(NDtree)
#

# Le code est suffisament claire pour pouvoir etre compris avec l'article d'Andrzej Jaszkiewicz et de Thibaut Lust : "ND-Tree-based update: a Fast Algorithm for the Dynamic Non-Dominance Problem", 07/11/2017.

const TAILLE_MAX_FEUILLE = Int32(10)
const DEBBUG = true

function maj!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}}) where T <: Real where U
    DEBBUG ? println("Tentative d'insertion de la solution : ", y, "\ndans la branche : ", som) : nothing
    global DEBBUG
    if isempty(som)
        DEBBUG ? println("Ajout de l'unique solution a la racine.") : nothing
        som.val = (ideal(som), nadir(som), [y])
        return true
    else
        if maj_sommet!(som, y)
            DEBBUG ? println("Insertion de la solution dans une branche partant de : ", som) : nothing
            insert!(som, y)
            return true
        end
    end
    return false
end

function domine_fortement(y1::Tuple{Array{U,1}, Array{T,1}}, y2::Tuple{Array{U,1}, Array{T,1}}) where U where T <: Real
    domination = true
    forte = false
    for i in 1:length(y1[2])
        domination &= y1[2][i] <= y2[2][i]
        forte |= y1[2][i] < y2[2][i]
    end
    return  domination && forte
end

function domine(y1::Tuple{Array{U,1}, Array{T,1}}, y2::Tuple{Array{U,1}, Array{T,1}}) where U where T <: Real
    domination = true
    for i in 1:length(y1[2])
        domination &= y1[2][i] <= y2[2][i]
    end
    return  domination
end

function maj_sommet!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}}) where T <: Real where U
    global DEBBUG
    if domine(som.val[2], y)
        DEBBUG ? println("La solution est dominee par le nadir local : ", som.val[2]) : nothing
        return false
    elseif domine(y, som.val[1])
        DEBBUG ? println("La solution domine l'ideal local : ", som.val[1]) : nothing
        suppr_branche!(som)
    elseif domine(som.val[1], y) || domine(y, som.val[2])
        DEBBUG ? println("La solution est comprise entre le nadir local : ", som.val[2], "\n et l'ideal local : ", som.val[1]) : nothing
        if isempty(som.succ)
            DEBBUG ? println("Il s'agit d'une feuille.") : nothing
            for ys in som.val[3]
                if domine(ys, y)
                    DEBBUG ? println("La solution est dominee dans la feuille par : ", ys) : nothing
                    return false
                elseif domine_fortement(y, ys)
                    DEBBUG ? println("La solution domine fortement dans la feuille : ", ys) : nothing
                    filter!(s -> s != ys, som.val[3])
                end
            end
        else
            DEBBUG ? println("Il ne 'sagit pas d'une feuille, la descente de l'arbre continue.") : nothing
            for suc in som.succ
                if !maj_sommet!(suc, y)
                    DEBBUG ? println("La solution n'est pas comprise dans ce successeur : ", suc) : nothing
                    return false
                elseif isempty(suc)
                    DEBBUG ? println("Le successeur est vide : ", suc) : nothing
                    suppr_som!(suc)
                end
            end
            DEBBUG ? println("Le sommet ne contient plus qu'un successeur, il est remplace par celui-ci : ", som.succ) : nothing
            if length(som.succ) == 1
                remplace_som!(som, som_tmp)
            end
        end
    end
    return true
end

function insert!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}}) where T <: Real where U
    global DEBBUG
    global TAILLE_MAX_FEUILLE
    if isempty(som.succ)
        DEBBUG ? println("Ajout de la solution a la feuille : ", som.val) : nothing
        append!(som.val[3], [y])
        DEBBUG ? println("La solution a ete ajoutee a la feuille : ", som.val) : nothing
        maj_nadir_zenith!(som, y)
        if length(som.val[3]) > TAILLE_MAX_FEUILLE
            DEBBUG ? println("La feuille et trop chargee, elle va etre decoupee en plusieurs autres feuilles.") : nothing
            split!(som)
        end
    else
        DEBBUG ? println("Tentative d'insertion dans le successeur le plus proche.") : nothing
        suc = som.succ[suc_le_plus_proche(som, y)]
        insert!(suc, y)
    end
end

function y_le_plus_eloigne(liste::Array{Tuple{Array{U,1}, Array{T,1}},1}) where T <:Real where U
    dist = zeros(length(liste))
    for i in 1:length(liste)
        for j in i+1:length(liste)
            local d = sum(liste[i][2].*liste[j][2])
            dist[i] += d
            dist[j] += d
        end
    end
    return liste[argmax(dist)]
end

function y_le_plus_eloigne2(y::Tuple{Array{U,1}, Array{T,1}}, som::Sommet)  where T <: Real where U
    dist = zeros(sum([length(suc.val[3]) for suc in som.succ]))
    I = 0
    for suc in som.succ
        for i in 1:length(suc.val[3])
            local d = sum(y[2].*suc.val[3][i][2])
            dist[I+i] += d
        end
        I += length(suc.val[3])
    end
    return som.val[3][argmax(dist)]
end

function split!(som::Sommet)
    global DEBBUG
    DEBBUG ? println("Decoupage du sommet en plusieurs feuilles.") : nothing
    y = y_le_plus_eloigne(som.val[3])
    aj_suc!(som, (ideal(som), nadir(som), [y]))
    lambda = ys -> ys != y
    filter!(lambda, som.val[3])
    maj_nadir_zenith!(som.succ[end], y)
    global TAILLE_MAX_FEUILLE
    nb_feuilles = Int32(floor(length(som.val[3])/TAILLE_MAX_FEUILLE))
    for i in 1:nb_feuilles # Il faut qu'il y ait suffisament de feuilles successeurs pour pouvoir y recaser toutes les solutions y.
        DEBBUG ? println("Creation d'une ", i+1, "-eme feuille.") : nothing
        y = y_le_plus_eloigne2(y, som)
        DEBBUG ? println("Ajout a la ", i+1, "-eme feuille de la solution ", y) : nothing
        local feuille = Sommet((ideal(som), nadir(som), [y]))
        aj_suc!(som, feuille)
        maj_nadir_zenith!(feuille, y)
        filter!(lambda, som.val[3]) # Le y du lambda pointe sur le y redfinit dans la boucle.
    end
    DEBBUG ? println("Repartition des solutions dans les nouvelles feuilles.") : nothing
    while !isempty(som.val[3])
        y = popfirst!(som.val[3])
        local ipp = suc_le_plus_proche(som, y)
        local feuille = som.succ[ipp]
        DEBBUG ? println("Deplacement de la solution : ", y, "\ndans la feuille : ", ipp) : nothing
        append!(feuille.val[3], [y])
        maj_nadir_zenith!(feuille, y)
    end
end

function profondeur(som::Sommet, solutions::Array{T,1}) where T
    if isempty(som.succ)
        append!(solutions, som.val[3])
    else
        for suc in som.succ
            profondeur(suc, solutions)
        end
    end
end

function get_solutions(som::Sommet) where T
    solutions = Array{Tuple{Array{Int32,1}, Array{Int32,1}},1}(undef,0)
    if isempty(som.succ)
        append!(solutions, som.val[3])
    else
        for suc in som.succ
            profondeur(suc, solutions)
        end
    end
    return solutions
end

function maj_nadir_zenith!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}}) where T <: Real where U
    DEBBUG ? println("Maj de l'ideal et du nadir dans le sommet : ", som) : nothing
    global DEBBUG
    drapeau = false
    if !domine(som.val[1], y)
        drapeau = true
        for i in 1:length(y)
            som.val[1][2][i] = min(som.val[1][2][i], y[2][i])
        end
    elseif !domine(y, som.val[2])
        drapeau = true
        for i in 1:length(y)
            som.val[2][2][i] = max(som.val[2][2][i], y[2][i])
        end
    end
    if drapeau && !isempty(som.pred)
        maj_nadir_zenith!(som.pred[1], y)
    end
    DEBBUG ? println("Maj terminee de l'ideal et du nadir dans le sommet : ", som) : nothing
end

function suc_le_plus_proche(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}},) where T <: Real where U
    ipp = 1
    dpp = sum(y[2].*(som.succ[1].val[1][2]+som.succ[1].val[2][2])) # Calcul de la distance de y par rapport au baricentre de l'ideal et du nadir
    for i in 2:length(som.succ)
        local tmp = sum(y[2].*(som.succ[i].val[1][2]+som.succ[i].val[2][2]))
        if dpp > tmp
            ipp = i
            dpp = tmp
        end
    end
    return ipp
end

function nadir(som::Sommet)
    if isempty(som)
        return (Int32.([]), Int32.([2^31-1, 2^31-1, 2^31-1]))
    else
        return som.val[2]
    end
end

function ideal(som::Sommet)
    if isempty(som)
        return (Int32.([]), Int32.([0, 0, 0]))
    else
        return som.val[1]
    end
end

function test_domination()
    y1 = (zeros(0), [1,2,3])
    y2 = (zeros(0), [1,2,3])
    @assert domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,3])
    y2 = (zeros(0), [2,2,3])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
    y1 = (zeros(0), [2,2,3])
    y2 = (zeros(0), [1,2,3])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,3])
    y2 = (zeros(0), [1,2,2])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,3])
    y2 = (zeros(0), [1,1,3])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [2,2,3])
    y2 = (zeros(0), [1,1,3])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [2,2,3])
    y2 = (zeros(0), [1,1,1])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [0,1,2])
    y2 = (zeros(0), [1,0,2])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,2])
    y2 = (zeros(0), [1,2,3])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
    y1 = (zeros(0), [1,1,3])
    y2 = (zeros(0), [2,2,3])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
    y1 = (zeros(0), [2,1,1])
    y2 = (zeros(0), [1,2,3])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,1,1])
    y2 = (zeros(0), [1,2,3])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
end

function test_NDtree()
    nb_obj = 3
    @time NDtree = Sommet()
    @time y1 = ([rand(1:10) for i in 1:10], [1,2,3])
    @time maj!(NDtree, y1)
    @assert !isempty(NDtree)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val) == 3
    @assert NDtree.val[3][1] == y1
    @assert NDtree.val[3][1] === y1
    for ys in NDtree.val[3]
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end
    @time y2 = ([rand(1:10) for i in 1:10], copy(y1[2]) - ones(typeof(y1[2][1]),length(y1[2])))
    @time maj!(NDtree, y2)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val[3]) == 1
    @assert NDtree.val[3][1] == y2
    @assert NDtree.val[3][1] === y2
    display(NDtree.val)
    for ys in NDtree.val[3]
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end
    y3 = deepcopy(y2)
    y3[2][1] += 1
    y3[2][2] -= 1
    @time maj!(NDtree, y3)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val[3]) == 2
    @assert NDtree.val[3][2] == y3
    @assert NDtree.val[3][2] === y3
    display(NDtree.val)
    for ys in NDtree.val[3]
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end

    y4 = deepcopy(y3)
    y4[2][1] += 1
    y4[2][2] -= 1
    @time maj!(NDtree, y4)
    @assert !isempty(NDtree.succ)
    @assert length(NDtree.succ) == 2
    display(NDtree.val)
    display(NDtree.succ)
    @assert isempty(NDtree.val[3])
    feuille1 = NDtree.succ[1]
    feuille2 = NDtree.succ[2]
    @assert y2 in union(feuille1.val[3], feuille2.val[3])
    @assert y3 in union(feuille1.val[3], feuille2.val[3])
    @assert y4 in union(feuille1.val[3], feuille2.val[3])
    display(feuille1.val[3])
    display(feuille2.val[3])
    @assert length(feuille1.val[3]) + length(feuille2.val[3]) == 3
    for ys in feuille1.val[3]
        @assert domine(ideal(feuille1), ys)
        @assert domine(ys, nadir(feuille1))
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end
    display(ideal(feuille1))
    for ys in feuille2.val[3]
        @assert domine(ideal(feuille2), ys)
        @assert domine(ys, nadir(feuille2))
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end

    y5 = deepcopy(y4)
    y5[2][1] += 1
    y5[2][2] -= 1
    @time maj!(NDtree, y5)
    @assert y5 in get_solutions(NDtree)
    @assert !isempty(NDtree.succ)
    @assert length(NDtree.succ) == 2
    noeud1 = NDtree.succ[1]
    feuille2 = NDtree.succ[2]
    feuille1 = noeud1.succ[1]
    feuille3 = noeud1.succ[2]
    @assert length(feuille2.val[3]) <= TAILLE_MAX_FEUILLE && isempty(feuille2.succ)
    @assert isempty(noeud1.val[3]) && !isempty(noeud1.succ)
    @assert length(noeud1.succ) == 2
    @assert length(feuille1.val[3]) + length(feuille3.val[3]) == 3
    @assert isempty(feuille1.succ) && isempty(feuille3.succ)
    @assert length(noeud1.pred) == 1 && length(feuille1.pred) == 1 && length(feuille2.pred) == 1 && length(feuille3.pred) == 1

    y6 = deepcopy(y5)
    y5[2][1] += 1
    @time drapeau = maj!(NDtree, y5);
    @assert !drapeau

    @time solutions = get_solutions(NDtree)
end