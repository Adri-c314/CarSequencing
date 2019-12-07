# Classe Sommet, pour le KDtree

try
    mutable struct Sommet
      pred::Array{Sommet}
      succ::Array{Sommet}
      val::T where T
      Sommet(T::Type = Int32) = new(Array{Sommet}(undef,0), Array{Sommet}(undef,0), zero(T))
      Sommet(val::T = Int32(0)) where T = new(Array{Sommet}(undef,0), Array{Sommet}(undef,0), val)
      Sommet(pred::Array{Sommet} = Array{Sommet}(undef,0), succ::Array{Sommet} = Array{Sommet}(undef,0), val::T = Int32(0)) where T = new(pred, succ, val)
    end
catch
    nothing
end

function Base.display(som::Sommet)
    println("Sommet")
    println("#predecesseurs : ", length(som.pred))
    println("#successeurs : ", length(som.succ))
    println("valeur : ", som.val)
end

# Ajoute un successeur
function aj_suc!(som::Sommet, val::T = Int32(0)) where T
    append!(som.succ, [Sommet(val)])
    append!(som.succ[end].pred, [som])
end

# Ajoute un successeur
function aj_suc!(som::Sommet, som_succ::Sommet)
    append!(som.succ, [som_succ])
    append!(som_succ.pred, [som])
end

function suppr_som!(som::Sommet)
    lambda = s::Sommet -> s != som
    for suc in som.succ
        filter!(lambda, suc.pred)
    end
    for pre in som.pred
        filter!(lambda, pre.succ)
    end
    empty!(som.pred)
    empty!(som.succ)
    if typeof(som.val) <: Number
        som.val = zero(som.val)
    elseif typeof(som.val) <: AbstractArray
        empty!(som.val)
    end
end

function suppr_branche!(som::Sommet)
    for suc in som.succ
        suppr_branche!(suc)
    end
    suppr_som!(som)
end

Base.isempty(val::T) where T <: Number = iszero(val);
Base.isempty(som::Sommet) = isempty(som.succ) && isempty(som.pred) && isempty(som.val);
Base.zero(som::Sommet) = return Sommet();
Base.iszero(som::Sommet) = isempty(som);
function Base.empty!(som::Sommet)
    empty!(som.pred)
    empty!(som.succ)
    typeof(som.val) <: Number ? som.val = zero(som.val) : som.val = empty(som.val)
end

function remplace_elem_tableau!(tableau::Array{T}, elem1::T, elem2::T) where T
    drapeau = true
    i = 1
    while drapeau
        drapeau = tableau[i] != elem1
        drapeau ? nothing : tableau[i] = elem2
        i += 1
    end
end

# Remplace le sommet 1 par le sommet 2.
function remplace_som!(som1::Sommet, som2::Sommet)
    som1.val = som2.val
    som1.succ = som2.succ
    for suc in som2.succ
        remplace_elem_tableau!(suc.pred, som2, som1)
    end
    lambda = s::Sommet -> s != som2
    for pre in som2.pred
        filter!(lambda, pre.succ)
    end
    #empty!(som2)
end

function test_Sommet()

    # Test des constructeurs
    Sommet()
    Sommet(1)
    Sommet(Array{Sommet}(undef,0), Array{Sommet}(undef,0), 1)

    # Test de l'ajout d'un nouveau successeur
    @time racine = Sommet()
    @time aj_suc!(racine)
    @assert racine.succ[end].pred[end] == racine

    # Test de l'ajout d'un successeur deja existant
    @time s1 = Sommet()
    @time s2 = Sommet()
    @time aj_suc!(racine,s1)
    @assert racine.succ[end] == s1
    @assert s1.pred[end] == racine
    @assert racine.succ[end] === s1
    @assert s1.pred[end] === racine

    @time aj_suc!(s1,s2)
    @assert s1.succ[end] == s2
    @assert s2.pred[end] == s1
    @assert racine.succ[end].succ[end] == s2
    @assert s1.succ[end] === s2
    @assert s2.pred[end] === s1
    @assert racine.succ[end].succ[end] === s2

    # Test de la suppression d'un sommet
    @time suppr_som!(s1)
    @assert isempty(s2.pred)
    @assert isempty(s1)
    for s in racine.succ
        @assert !(s == s1)
    end
    for s in s2.pred
        @assert !(s == s1)
    end
    for s in racine.succ
        @assert !(s === s1)
    end
    for s in s2.pred
        @assert !(s === s1)
    end
    @assert isempty(racine.pred)
    @time suppr_som!(s2)
    @assert isempty(s2)
    @assert length(racine.succ) == 1
    for s in racine.succ
        @assert !(s === s1)
        @assert !(s === s2)
    end

    # Test de la suppression d'un sommet et de toute la branche qui suit
    @time racine = Sommet()
    @time s1 = Sommet()
    @time s2 = Sommet()
    @time s3 = Sommet()
    @time aj_suc!(racine,s1)
    @time aj_suc!(racine,s3)
    @time aj_suc!(s1, s2)

    @time suppr_branche!(racine)
    @assert isempty(s1)
    @assert isempty(s2)
    @assert isempty(s3)
    @assert isempty(racine)
#=
# Test sur les pointeurs en Julia
    i = 1
    v = collect(1:3)
    for elem in v
        @assert v[i] === elem
        i += 1
    end
    i = 1
    v = collect(1:3)
    for elem in values(v)
        @assert v[i] === elem
        i += 1
    end
=#
    # Test du remplacement d'un sommet par son successeur
    @time racine = Sommet()
    @time s1 = Sommet()
    @time s2 = Sommet()
    @time s3 = Sommet()
    @time aj_suc!(racine,s1)
    @time aj_suc!(racine,s3)
    @time aj_suc!(s1, s2)
    @time aj_suc!(s3)
    @assert !isempty(s1.succ)
    @assert !isempty(s1.pred)
    @assert !isempty(s3.pred)
    @assert !isempty(s3.succ)
    println("s1 : ")
    display(s1)
    println("s3 : ")
    display(s3)
    remplace_som!(s1, s3)
    println("s1 : ")
    display(s1)
    println("s3 : ")
    display(s3)
    @assert s1.val == s3.val
    @assert s1.succ == s3.succ
    @assert s1.val === s3.val
    @assert s1.succ === s3.succ
    for suc in s1.succ
        @assert s1 in suc.pred
        @assert !(s3 in suc.pred)
    end
    for pre in s1.pred
        @assert s1 in pre.succ
        @assert !(s3 in pre.succ)
    end
end

#test_Sommet()
