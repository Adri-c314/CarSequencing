# NDtree, sert a stocker l'ensemble de Pareto
#
# Cas d'utilisation :
#
# 1) Instanciation :
# NDtree = Sommet()
#
# 2) Tentative d'insertion d'une nouvelle solution y::Tuple{Array{Array{Int32,1},1}, Array{Int32,1}, Q}.
#    Exemple de y : (sequence des vehicules, [RAF, EP, ENP], table_violation).
#    (Bien conserver cet ordre pour les objectifs.)
# maj!(NDtree, y) # Retourne un boolean qui dit si la solution est efficasse et a ete inseree.
#    NB : Les y sont stockes par reference et pas deepcopies.
#
# 3) Lecture de toutes les solutions inserees
# solutions = get_solutions(NDtree)
#
# 4) Ploter les solutions
# plot_pareto(solutions ; file_name = "instance") # Puis le graphique est enregistre dans "./Output/plots"
#
# 5) Enregistre les solutions dans un CSV
# CSV_pareto(solutions ; file_name = "instance") # Enregistre dans "./Output/CSV"
#
# 6) Nadir et ideal global
# nadir = nadir_global(NDtree)
# ideal = ideal_global(NDtree)
#
# 7) Recuperer les extremes lexicographiques
# y_extr = y_extremes(NDtree)
#
# 8) Recuperer les solutions plus le nadir global
# solutions, nadir_global = get_solutions_plus_nadir(NDtree)
#
# 9) Recuperer les solutions plus les extremes lexicographiques
# solutions, extremes = get_solutions_plus_extremes(NDtree)
#
# 10) Filtrer les .csv non filtres et les enregistre au format blalbla_filtre.csv
# filtrage_csv()
#

# Le code est suffisament claire pour pouvoir etre compris avec l'article d'Andrzej Jaszkiewicz et de Thibaut Lust : "ND-Tree-based update: a Fast Algorithm for the Dynamic Non-Dominance Problem", 07/11/2017.

const TAILLE_MAX_FEUILLE = Int32(2)
const DEBBUG = false

function maj!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}, Q}) where T <: Real where U where Q
    #global DEBBUG
    #DEBBUG ? println("Tentative d'insertion de la solution : ", y, "\ndans la branche : ", som) : nothing
    if isempty(som)
        #DEBBUG ? println("Ajout de l'unique solution a la racine.") : nothing
        som.val = (deepcopy(ideal(som)), deepcopy(nadir(som)), [deepcopy(y)])
        return true
    else
        if maj_sommet!(som, y)
            #DEBBUG ? println("Insertion de la solution dans une branche partant de : ", som) : nothing
            insert!(som, y)
            return true
        end
    end
    return false
end

function domine_fortement(y1::Tuple{Array{U,1}, Array{T,1}, Q}, y2::Tuple{Array{V,1}, Array{W,1}, R}) where U where V where Q where R where T <: Real where W <: Real
    domination = true
    forte = false
    for i in 1:length(y1[2])
        domination &= y1[2][i] <= y2[2][i]
        forte |= y1[2][i] < y2[2][i]
    end
    return  domination && forte
end

function domine(y1::Tuple{Array{U,1}, Array{T,1}, Q}, y2::Tuple{Array{V,1}, Array{W,1}, R}) where U where V where Q where R where T <: Real where W <: Real
    domination = true
    for i in 1:length(y1[2])
        domination &= y1[2][i] <= y2[2][i]
    end
    return  domination
end

function maj_sommet!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}, Q}) where T <: Real where U where Q
    #global DEBBUG
    if domine(som.val[2], y)
        #DEBBUG ? println("La solution est dominee par le nadir local : ", som.val[2]) : nothing
        return false
    elseif domine(y, som.val[1])
        #DEBBUG ? println("La solution domine l'ideal local : ", som.val[1]) : nothing
        suppr_branche!(som)
    elseif domine(som.val[1], y) || domine(y, som.val[2])
        #DEBBUG ? println("La solution est comprise entre le nadir local : ", som.val[2], "\n et l'ideal local : ", som.val[1]) : nothing
        if isempty(som.succ)
            #DEBBUG ? println("Il s'agit d'une feuille.") : nothing
            for ys in som.val[3]
                if domine(ys, y)
                    #DEBBUG ? println("La solution est dominee dans la feuille par : ", ys) : nothing
                    return false
                elseif domine_fortement(y, ys)
                    #DEBBUG ? println("La solution domine fortement dans la feuille : ", ys) : nothing
                    filter!(s -> s != ys, som.val[3])
                end
            end
        else
            #DEBBUG ? println("Il ne 'sagit pas d'une feuille, la descente de l'arbre continue.") : nothing
            for suc in som.succ
                if !maj_sommet!(suc, y)
                    #DEBBUG ? println("La solution n'est pas comprise dans ce successeur : ", suc) : nothing
                    return false
                elseif isempty(suc)
                    #DEBBUG ? println("Le successeur est vide : ", suc) : nothing
                    suppr_som!(suc)
                end
            end
            #DEBBUG ? println("Le sommet ne contient plus qu'un successeur, il est remplace par celui-ci : ", som.succ) : nothing
            if length(som.succ) == 1
                remplace_som!(som, som.succ[1])
            end
        end
    end
    return true
end

function insert!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}, Q}) where T <: Real where U where Q
    #global DEBBUG
    global TAILLE_MAX_FEUILLE
    if isempty(som.succ)
        #DEBBUG ? println("Ajout de la solution a la feuille : ", som.val) : nothing
        append!(som.val[3], [deepcopy(y)])
        #DEBBUG ? println("La solution a ete ajoutee a la feuille : ", som.val) : nothing
        maj_nadir_ideal!(som, y)
        if length(som.val[3]) > TAILLE_MAX_FEUILLE
            #DEBBUG ? println("La feuille et trop chargee, elle va etre decoupee en plusieurs autres feuilles.") : nothing
            split!(som)
        end
    else
        #DEBBUG ? println("Tentative d'insertion dans le successeur le plus proche.") : nothing
        suc = som.succ[suc_le_plus_proche(som, y)]
        insert!(suc, y)
    end
end

function y_le_plus_eloigne(liste::Array{Tuple{Array{U,1}, Array{T,1}, Q},1}) where T <:Real where U where Q
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

function y_le_plus_eloigne2(y::Tuple{Array{U,1}, Array{T,1}, Q}, som::Sommet)  where T <: Real where U where Q
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
    #global DEBBUG
    #DEBBUG ? println("Decoupage du sommet en plusieurs feuilles.") : nothing
    y = y_le_plus_eloigne(som.val[3])
    aj_suc!(som, ((Int32.([]), copy(y[2]), Int32.([])), (Int32.([]), copy(y[2]), Int32.([])), [y]))
    lambda = ys -> ys != y
    filter!(lambda, som.val[3])
    maj_nadir_ideal!(som.succ[end], y)
    global TAILLE_MAX_FEUILLE
    nb_feuilles = Int32(floor(length(som.val[3])/TAILLE_MAX_FEUILLE))
    for i in 1:nb_feuilles # Il faut qu'il y ait suffisament de feuilles successeurs pour pouvoir y recaser toutes les solutions y.
        #DEBBUG ? println("Creation d'une ", i+1, "-eme feuille.") : nothing
        y = y_le_plus_eloigne2(y, som)
        #DEBBUG ? println("Ajout a la ", i+1, "-eme feuille de la solution ", y) : nothing
        local feuille = Sommet(((Int32.([]), copy(y[2]), Int32.([])), (Int32.([]), copy(y[2]), Int32.([])), [y]))
        aj_suc!(som, feuille)
        maj_nadir_ideal!(feuille, y)
        filter!(lambda, som.val[3]) # Le y du lambda pointe sur le y redfinit dans la boucle.
    end
    #DEBBUG ? println("Repartition des solutions dans les nouvelles feuilles.") : nothing
    while !isempty(som.val[3])
        y = popfirst!(som.val[3])
        local ipp = suc_le_plus_proche(som, y)
        local feuille = som.succ[ipp]
        #DEBBUG ? println("Deplacement de la solution : ", y, "\ndans la feuille : ", ipp) : nothing
        append!(feuille.val[3], [y])
        maj_nadir_ideal!(feuille, y)
    end
end

function profondeur(som::Sommet, solutions::Array{T,1}) where T
    if isempty(som.succ)
        try
            append!(solutions, som.val[3])
        catch
            println("ERROR get_solutions(NDtree), solutions pas retournees : ", som.val[3], "\n")
        end
    else
        for suc in som.succ
            profondeur(suc, solutions)
        end
    end
end

function get_solutions(som::Sommet)
    solutions = Array{Tuple{Array{Any,1}, Array{Int,1}, Any},1}(undef, 0)
    if isempty(som.succ)
        try
            append!(solutions, som.val[3])
        catch
            println("ERROR get_solutions(NDtree), solutions pas retournees : ", som.val[3], "\n")
        end
    else
        for suc in som.succ
            profondeur(suc, solutions)
        end
    end
    return solutions
end


function profondeur_nadir(som::Sommet, solutions::Array{T,1}, nadir_::Array{N,1}) where T where N <: Number
    if isempty(som.succ)
        try
            append!(solutions, som.val[3])
            for y in som.val[3]
                for i in 1:length(y[2])
                    y[2][i] > nadir_[i] ? nadir_[i] = y[2][i] : nothing
                end
            end
        catch
            println("ERROR get_solutions_plus_nadir(NDtree), solutions pas retournees : ", som.val[3], "\n")
        end
    else
        for suc in som.succ
            profondeur_nadir(suc, solutions, nadir_)
        end
    end
end

function get_solutions_plus_nadir(som::Sommet ; nb_obj::Int = 3)
    solutions = Array{Tuple{Array{Any,1}, Array{Int,1}, Any},1}(undef, 0)
    nadir_ = fill(Int32(-1), nb_obj)
    if isempty(som.succ)
        try
            append!(solutions, som.val[3])
            for y in som.val[3]
                for i in 1:length(y[2])
                    y[2][i] > nadir_[i] ? nadir_[i] = y[2][i] : nothing
                end
            end
        catch
            println("ERROR get_solutions_plus_nadir(NDtree), solutions pas retournees : ", som.val[3], "\n")
        end
    else
        for suc in som.succ
            profondeur_nadir(suc, solutions, nadir_)
        end
    end
    return solutions, nadir_
end

function profondeur_extremes(som::Sommet, solutions::Array{T,1}, extremes::Array{T,1}) where T
    if isempty(som.succ)
        try
            append!(solutions, som.val[3])
            if isempty(extremes)
                for i in 1:length(som.val[3][1][2])
                    append!(extremes, [som.val[3][1]])
                end
            end
            for y in som.val[3]
                for i in 1:length(y[2])
                    y[2][i] > extremes[i][2][i] ? extremes[i] = y : nothing
                end
            end
        catch
            println("ERROR get_solutions_plus_extremes(NDtree), solutions pas retournees : ", som.val[3], "\n")
        end
    else
        for suc in som.succ
            profondeur_extremes(suc, solutions, extremes)
        end
    end
end

function get_solutions_plus_extremes(som::Sommet ; nb_obj::Int = 3)
    solutions = Array{Tuple{Array{Any,1}, Array{Int,1}, Any},1}(undef, 0)
    extremes = Array{Tuple{Array{Any,1}, Array{Int,1}, Any},1}(undef, 0)
    if isempty(som.succ)
        try
            append!(solutions, som.val[3])
            if isempty(extremes)
                for i in 1:length(som.val[3][1][2])
                    append!(extremes, [som.val[3][1]])
                end
            end
            for y in som.val[3]
                for i in 1:length(y[2])
                    y[2][i] > extremes[i][2][i] ? extremes[i] = y : nothing
                end
            end
        catch
            println("ERROR get_solutions_plus_extremes(NDtree), solutions pas retournees : ", som.val[3], "\n")
        end
    else
        for suc in som.succ
            profondeur_extremes(suc, solutions, extremes)
        end
    end
    return solutions, extremes
end

function maj_nadir_ideal!(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}, Q}) where T <: Real where U where Q
    #global DEBBUG
    #DEBBUG ? println("Maj de l'ideal et du nadir dans le sommet : ", som) : nothing
    drapeau = false
    if !domine(som.val[1], y)
        drapeau = true
        for i in 1:length(y[2])
            som.val[1][2][i] = min(som.val[1][2][i], y[2][i])
        end
    end
    if !domine(y, som.val[2])
        drapeau = true
        for i in 1:length(y[2])
            som.val[2][2][i] = max(som.val[2][2][i], y[2][i])
        end
    end
    if drapeau && !isempty(som.pred)
        maj_nadir_ideal!(som.pred[1], y)
    end
    #DEBBUG ? println("Maj terminee de l'ideal et du nadir dans le sommet : ", som) : nothing
end

function suc_le_plus_proche(som::Sommet, y::Tuple{Array{U,1}, Array{T,1}, Q},) where T <: Real where U where Q
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
        return (Int32.([]), Int32.([2^31-1, 2^31-1, 2^31-1]), Int32.([]))
    else
        return som.val[2]
    end
end

function ideal(som::Sommet)
    if isempty(som)
        return (Int32.([]), Int32.([1-2^31, 1-2^31+1, 1-2^31]), Int32.([]))
    else
        return som.val[1]
    end
end

function test_domination()
    y1 = (zeros(0), [1,2,3], [])
    y2 = (zeros(0), [1,2,3], [])
    @assert domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,3], [])
    y2 = (zeros(0), [2,2,3], [])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
    y1 = (zeros(0), [2,2,3], [])
    y2 = (zeros(0), [1,2,3], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,3], [])
    y2 = (zeros(0), [1,2,2], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,3], [])
    y2 = (zeros(0), [1,1,3], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [2,2,3], [])
    y2 = (zeros(0), [1,1,3], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [2,2,3], [])
    y2 = (zeros(0), [1,1,1], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [0,1,2], [])
    y2 = (zeros(0), [1,0,2], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,2,2], [])
    y2 = (zeros(0), [1,2,3], [])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
    y1 = (zeros(0), [1,1,3], [])
    y2 = (zeros(0), [2,2,3], [])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
    y1 = (zeros(0), [2,1,1], [])
    y2 = (zeros(0), [1,2,3], [])
    @assert !domine(y1, y2)
    @assert !domine_fortement(y1,y2)
    y1 = (zeros(0), [1,1,1], [])
    y2 = (zeros(0), [1,2,3], [])
    @assert domine(y1, y2)
    @assert domine_fortement(y1,y2)
end

function test_NDtree()
    nb_obj = 3
    @time NDtree = Sommet()
    @time y1 = (Int32.([rand(1:10) for i in 1:10]), Int32.([1,2,3]), [])
    @assert maj!(NDtree, y1)
    @assert !isempty(NDtree)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val) == 3
    @assert NDtree.val[3][1] == y1
    @assert !(NDtree.val[3][1] === y1)
    for ys in NDtree.val[3]
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end
    @time y2 = (y1[1], y1[2] - ones(typeof(y1[2][1]), length(y1[2])), y1[3])
    @assert maj!(NDtree, y2)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val[3]) == 1
    @assert NDtree.val[3][1] == y2
    @assert !(NDtree.val[3][1] === y2)
    display(NDtree.val)
    for ys in NDtree.val[3]
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end
    y3 = y2
    y3[2][1] += 1
    y3[2][2] -= 1
    @assert maj!(NDtree, y3)
    @assert isempty(NDtree.succ)
    @assert length(NDtree.val[3]) == 2
    @assert NDtree.val[3][2] == y3
    @assert !(NDtree.val[3][2] === y3)
    display(NDtree.val)
    for ys in NDtree.val[3]
        @assert domine(ideal(NDtree), ys)
        @assert domine(ys, nadir(NDtree))
    end
    y4 = deepcopy(y3)
    y4[2][1] += 1
    y4[2][2] -= 1
    @assert maj!(NDtree, y4)
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

    y5 = y4
    y5[2][1] += 1
    y5[2][2] -= 1
    @time maj!(NDtree, y5)
    @assert y5 in get_solutions(NDtree)
    @assert !isempty(NDtree.succ)
    @assert length(NDtree.succ) == 2
    feuille1 = NDtree.succ[1]
    feuille2 = NDtree.succ[2]
    @assert length(feuille2.val[3]) <= TAILLE_MAX_FEUILLE && isempty(feuille2.succ)
    @assert length(feuille1.val[3]) <= TAILLE_MAX_FEUILLE && isempty(feuille1.succ)
    @assert length(feuille1.val[3]) + length(feuille2.val[3])  == 4
    display(ideal(feuille1))
    display(ideal(feuille2))
    display(nadir(NDtree))
    display(nadir(feuille1))
    display(nadir(feuille2))
    display(nadir(NDtree))

    y6 = y5
    y5[2][1] += 1
    @time drapeau = maj!(NDtree, y5);
    @assert !drapeau

    @time solutions = get_solutions(NDtree)
    println("Pareto : ", solutions)
    println("Nadir global : ", nadir_global(NDtree))
    println("Ideal global : ", ideal_global(NDtree))
    extremes = y_extremes(NDtree)
    println("extremes : ", [y[2] for y in extremes])
    solutions2, extremes2 = get_solutions_plus_extremes(NDtree)
    try
        for i in 1:length(extremes[1][2])
            @assert extremes[i][2][i] in [extremes2[j][2][i] for j in 1:length(extremes2)]
        end
    catch
        println("extremes : ", [y[2] for y in extremes])
        println("extremes2 : ", [y[2] for y in extremes2])
        for i in 1:length(extremes[1][2])
            @assert extremes[i][2][i] in [extremes2[j][2][i] for j in 1:length(extremes2)]
        end
    end

    @time solutions2, nadir2 = get_solutions_plus_nadir(NDtree)
    try
        @assert nadir2 == nadir_global(NDtree)
    catch
        println("nadir : ", nadir_global(NDtree))
        println("nadir2 : ", nadir2)
        @assert nadir2 == nadir_global(NDtree)
    end
    @assert solutions == solutions2

    pareto = get_solutions(NDtree)

    x = [ys[2][1] for ys in pareto]
    y = [ys[2][2] for ys in pareto]
    z = [ys[2][3] for ys in pareto]

    scatter(x, y, z, xlabel = "RAF", ylabel = "EP", zlabel = "ENP")
    try
        mkdir("./Plots")
    catch
        nothing
    end
    savefig("./Plots/plot1.png")

    directory = "./Output/CSV"
    try
        mkdir(directory)
    catch
        nothing
    end
    CSV_pareto(pareto)
    plot_pareto(pareto)

    hyperv = hypervolume(NDtree)
end

try
    using Plots
catch
    using Pkg
    Pkg.add("Plots")
    using Plots
finally
    pyplot()
end

try
    mkdir("./Output")
catch
    nothing
end

# Fonction qui plot une archive de Pareto et l'enregistre
# @param pareto : l'archive de Pareto
# @param file_name : nom du fichier (de l'instance par exemple)
# @param directory : dossier ou est enregistrer le graphique
function plot_pareto(pareto::Array{Tuple{Array{U,1}, Array{T,1}, Q},1} ; xlabel::String = "RAF", ylabel::String = "EP", zlabel::String = "ENP", directory::String = "./Output/plots/", file_name::String = "instance", verbose::Bool = true) where U where Q where T <: Number
    if !isempty(pareto)
        try
            mkdir(directory)
        catch
            nothing
        end
        x = [ys[2][1] for ys in pareto]
        y = [ys[2][2] for ys in pareto]
        z = [ys[2][3] for ys in pareto]
        scatter(x, y, z, xlabel = xlabel, ylabel = ylabel, zlabel = zlabel)
        nb_plots = length(readdir(directory))
        savefig(directory * "/" * file_name * ".png")
        if verbose
            println("   ----------------------------------")
            println("   Enregistrement du plot de Pareto dans : ", directory * "/" * file_name * ".png" )
        end
    end
end

try
    using CSV
catch
    using Pkg
    Pkg.add("CSV")
    using CSV
end

try
    using DataFrames
catch
    using Pkg
    Pkg.add("DataFrames")
    using DataFrames
end

# Fonction qui enregistre une archive de Pareto dans un fichier CSV
# @param pareto : l'archive de Pareto
# @param file_name : nom du fichier (de l'instance par exemple)
# @param directory : dossier ou est enregistrer le .csv
function CSV_pareto(pareto::Array{Tuple{Array{U,1}, Array{T,1}, Q},1} ; file_name::String = "instance", directory::String = "./Output/CSV", verbose::Bool = true) where U where Q where T <: Number
    if !isempty(pareto)
        try
            mkdir(directory)
        catch
            nothing
        end
        df = DataFrame(pareto)
        names!(df, [:Solution, :Obj, :Ctr])
        CSV.write(directory * "/" * file_name * ".csv", df, writeheader=true)
        if verbose
            println("   ----------------------------------")
            println("   Enregistrement de l'ensemble de Pareto dans : ", directory * "/" * file_name * ".csv" )
        end
    end
end

function hypervolume(NDtree::Sommet ; verbose::Bool = true)
    solutions = get_solutions(NDtree)
    maxRAF = maximum([y[2][1] for y in solutions])
    maxEP = maximum([y[2][2] for y in solutions])
    maxENP = maximum([y[2][3] for y in solutions])
    hyperv = 0
    for i in -1:maxRAF
        for j in -1:maxEP
            for k in -1:maxENP
                local drapeau = false
                local n = 1
                local y = (Int32.([]),Int32.([1,1,1]),Int32.([]))
                while !drapeau && n <= length(solutions)
                    y[2][1] = Int32(i)
                    y[2][1] = Int32(j)
                    y[2][1] = Int32(k)
                    drapeau = domine(y, solutions[n])
                    if drapeau
                        hyperv += 1
                    end
                    n += 1
                end
            end
        end
    end
    if verbose
        println("   ----------------------------------")
        println("   L'hypervolume du NDtree vaut : ", hyperv)
    end
    return hyperv
end

function nadir_global(NDtree::Sommet)
    pareto = get_solutions(NDtree)
    if isempty(pareto)
        return Int32.([2^31-1, 2^31-1, 2^31-1])
    else
        return [maximum([y[2][i] for y in pareto ]) for i in 1:length(pareto[1][2]) ]
    end
end

function ideal_global(NDtree::Sommet)
    pareto = get_solutions(NDtree)
    if isempty(pareto)
        return Int32.([2^31-1, 2^31-1, 2^31-1])
    else
        return [minimum([y[2][i] for y in pareto ]) for i in 1:length(pareto[1][2]) ]
    end
end

# @return tableaux des solutions extremes (lexicographiquement)
function y_extremes(NDtree::Sommet)
    pareto = get_solutions(NDtree)
    if isempty(pareto)
        return []
    else
        y_extr = [pareto[1] for i in 1:length(pareto[1][2])]
        for y in pareto
            for i in 1:length(y[2])
                if y_extr[i][2][i] >= y[2][i]
                    y_extr[i] = y
                end
            end
        end
        return y_extr
    end
end

function filtrage!(pareto::Array{Tuple{Array{U,1}, Array{T,1}, Q},1})  where T <: Real where U where Q
    exclus = Array{Tuple{Array{U,1}, Array{T,1}, Q},1}(undef,0)
    for i in 1:length(pareto)
        local domination = true
        for j in 1:length(pareto)
            if i != j
                domination &= !domine_fortement(pareto[j], pareto[i])
            end
        end
        if !domination
            append!(exclus, [pareto[i]])
        end
    end
    lambda = ys -> !(ys in exclus)
    filter!(lambda, pareto)
end

# Fonction qui isnere une solution efficasse dans une liste, pour comparer avec le NDtree
function maj!(liste::Array{Tuple{Array{U,1}, Array{T,1}, Q},1}, y::Tuple{Array{U,1}, Array{T,1}, Q}) where T <: Real where U where Q
    drapeau = true
    i = 1
    while drapeau && length(liste) >= i
        drapeau &= !domine(liste[i], y)
        i += 1
    end
    if drapeau
        append!(liste, [y])
        filter!(ys -> !domine_fortement(y, ys), liste)
    end
    return drapeau
end

function test_NDtree2(nb_y::Int = 100 ; d::Int = 2)
    NDtree = Sommet()
    random_y = (dim::Int = d) -> (Int32.([]), Int32.([rand(1:nb_y) for i in 1:dim]), Int32.([]))
    y = random_y()
    liste = [y]
    @assert maj!(NDtree,y)
    for i in 1:nb_y
        y = random_y()
        local insertND = maj!(NDtree,y)
        local insertListe = maj!(liste,y)
        try
            @assert insertND == insertListe
        catch
            @assert insertND > insertListe
            println("z(y) : ", y[2], " insere dans NDtree mais pas dans liste.")
        end
    end
    pareto = get_solutions(NDtree)
    for y in liste
        @assert y in pareto
    end
    try
        @assert length(pareto) == length(liste)
    catch
        @assert length(pareto) > length(liste)
        println("length(pareto) : ", length(pareto), " > ", "length(liste) : ", length(liste))
        filtrage!(pareto)
        println("length(pareto) : ", length(pareto), " ; ", "length(liste) : ", length(liste))
        @assert length(pareto) == length(liste)
        for y in liste
            @assert y in pareto
        end
    end
end

# Fonction qui lit tous les .csv dans Output
# et filtre par dominance ceux qui ne contiennent que les 3 colonnes d'objectif.
# Enregistre les nouveaux au format blalbla_filtre.csv.
function filtrage_csv(onLinux::Bool = true)
    path = string("../../Output/")
    paths = (string(path, "A/"), string(path, "B/"), string(path, "X/"), string(path, "PLS/"))
    for pt in paths
        instances = readdir(pt)
        for inst in instances
            if length(inst) >= 4
                if inst[end-2:end] == "csv" &&  inst[end-10:end-4] != "_filtre"
                    path_tmp = string(pt, "/", inst)
                    file = pathOS(path_tmp, onLinux)
                    flux = CSV.read(file,ignoreemptylines=true)
                    vrai_pareto = Array{Array{Int,1},1}(undef,0)
                    if length((flux)) == 3
                        solutions = convert(Matrix, flux)
                        for i in size(solutions)[1]
                            z1 = solutions[i,:]
                            domination = true
                            for j in size(solutions)[1]
                                if i != j
                                    z2 = solutions[j,:]
                                    domination &= !domine_fortement(([],z2,[]), ([],z1,[]))
                                end
                            end
                            if domination
                                append!(vrai_pareto, [deepcopy(z1)])
                            end
                        end
                        tmp = ""
                        try
                            @assert !isempty(vrai_pareto) && !isempty(flux)
                        catch
                            println("")
                            println("ERREUR, signaler Xavier svp.")
                            println("")
                            @assert !isempty(vrai_pareto) && !isempty(flux)
                        end
                        for i in 1:length(vrai_pareto)
                            tmp = string(tmp, vrai_pareto[i][1]," ", vrai_pareto[i][2]," ", vrai_pareto[i][3],"\n")
                        end
                        println("Filtrage enregistre dans : ", pathOS(string(file[1:end-3],"_filtre.csv"), onLinux))
                        ecriture(tmp, pathOS(string(file[1:end-3],"_filtre.csv"), onLinux))
                    end
                end
            end
        end
    end
end

#filtrage_csv()

#test_domination()
#test_NDtree()
#test_NDtree2(100000, d = 3)
