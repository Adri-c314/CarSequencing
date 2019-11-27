const TAILLE_MAX_FEUILLE = Int32(2)
const DEBBUG = true

function maj!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}}) where T <: Real where U
    DEBBUG ? println("Tentative d'insertion de la solution : ", y, "\ndans la branche : ", som) : nothing
    global DEBBUG
    if isempty(som)
        DEBBUG ? println("Ajout de l'unique solution a la racine.") : nothing
        som.val = [ideal(som), nadir(som), y]
    else
        if maj_sommet!(som, y)
            DEBBUG ? println("Insertion de la solution dans une branche partant de : ", som) : nothing
            insert!(som, y)
        end
    end
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
            for ys in som.val[3:end]
                if domine(ys, y)
                    DEBBUG ? println("La solution est dominee dans la feuille par : ", ys) : nothing
                    return false
                elseif domine_fortement(y, ys)
                    DEBBUG ? println("La solution domine fortement dans la feuille : ", ys) : nothing
                    filter!(s -> s != ys, som.val)
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
        append!(som.val, [y])
        DEBBUG ? println("La solution a ete ajoutee a la feuille : ", som.val) : nothing
        maj_nadir_zenith!(som, y)
        if length(som.val)-2 > TAILLE_MAX_FEUILLE
            DEBBUG ? println("La feuille et trop chargee, elle va etre decoupee en plusieurs autres feuilles.") : nothing
            split!(som)
        end
    else
        DEBBUG ? println("Tentative d'insertion dans le successeur le plus proche.") : nothing
        suc = suc_le_plus_proche(som, y)
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
    @assert isempty(som.succ)
    dist = zeros(sum([length(suc.val) for suc in som.succ]))
    I = 0
    for suc in som.succ
        @assert !isempty(suc.succ)
        for i in 1:length(suc.val)
            local d = sum(y[2].*suc.val[i][2])
            dist[I+i] += d
            dist[I+j] += d
        end
        I += length(suc.val)
    end
    return liste[argmax(dist)]
end

function split!(som::Sommet)
    global DEBBUG
    DEBBUG ? println("Decoupage du sommet en plusieurs feuilles.") : nothing
    y = y_le_plus_eloigne(som.val)
    aj_suc!(som, [ideal(som), nadir(som), y])
    lambda = ys -> ys != y
    filter!(lambda, som.val)
    maj_nadir_zenith!(som.succ[end], y)
    global TAILLE_MAX_FEUILLE
    while TAILLE_MAX_FEUILLE/(length(som.val)-2) > length(som.succ) # Il faut qu'il y ait suffisament de feuilles successeurs pour pouvoir y recaser toutes les solutions y.
        DEBBUG ? println("Creation d'une nouvelle feuille.") : nothing
        y = y_le_plus_eloigne2(y, som)
        aj_suc!(som, [ideal(som), nadir(som), y])
        maj_nadir_zenith!(som.succ[end], y)
        filter!(lambda, som.val) # Le y du lambda pointe sur le y redfinit dans la boucle.
    end
    DEBBUG ? println("Repartition des solutions dans les nouvelles feuilles.") : nothing
    while !isempty(som.val[3:end])
        y = popfirst!(som.val[3:end])
        local feuille = suc_le_plus_proche(som, y)
        maj_nadir_zenith!(feuille, y)
    end
end

function get_solutions(som::Sommet, solutions::Array{T,1} = Array{Tuple{Array{Int32,1}, Array{Int32,1}},1}(undef,0), drapeau::Bool = true) where T
    if isempty(som.succ)
        append!(solutions, som.val[3:end])
    else
        for suc in som.succ
            profondeur(som, solutions, false)
        end
    end
    if drapeau
        return solutions
    end
end

function maj_nadir_zenith!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}}) where T <: Real where U
    DEBBUG ? println("Maj du zenith et du nadir dans le sommet : ", som) : nothing
    global DEBBUG
    drapeau = false
    if domine(y, som.val[1])
        drapeau = true
        for i in 1:length(y)
            som.val[1][2][i] = min(som.val[1][2][i], y[2][i])
        end
    elseif domine(som.val[2], y)
        drapeau = true
        for i in 1:length(y)
            som.val[2][2][i] = max(som.val[2][2][i], y[2][i])
        end
    end
    if drapeau && !isempty(som.pred)
        maj_nadir_zenith!(som.pred[1], y)
    end
    DEBBUG ? println("Maj terminee du zenith et du nadir dans le sommet : ", som) : nothing
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
    return som.succ[ipp]
end

function nadir(som::Sommet)
    if isempty(som)
        return (Int64.([]), Int64.([2^31-1, 2^31-1, 2^31-1]))
    else
        return som.val[2]
    end
end

function ideal(som::Sommet)
    if isempty(som)
        return (Int64.([]), Int64.([0, 0, 0]))
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
    @assert NDtree.val[3] == y1
    @assert NDtree.val[3] === y1

    @time y2 = ([rand(1:10) for i in 1:10], copy(y1[2]) - ones(typeof(y1[2][1]),length(y1[2])))
    @time maj!(NDtree, y2)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val) == 3
    @assert NDtree.val[3] == y2
    @assert NDtree.val[3] === y2
    display(NDtree.val)

    y3 = deepcopy(y2)
    y3[2][1] += 1
    y3[2][2] -= 1
    @time maj!(NDtree, y3)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val) == 4
    @assert NDtree.val[4] == y3
    @assert NDtree.val[4] === y3
    display(NDtree.val)

    y4 = deepcopy(y3)
    y4[2][1] += 1
    y4[2][2] -= 1
    @time maj!(NDtree, y4)
    @assert !isempty(NDtree.succ)
    display(NDtree.val)
    @assert length(NDtree.val) == 4
    @assert NDtree.val[4] == y3
    @assert NDtree.val[4] === y3
    display(NDtree.val)

    @time solutions = get_solutions(NDtree)
end
