# Fichier tous les algorithms gloutons et leurs foncions associées
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 1
using Random
Random.seed!(0)


# Fonction avec un nom generic
# @param size : la taille max
# @return Array{Int64,1} : une position aleatoire
function generic(size::Int64)
    a = rand(1:size,2)
    return a
end



# Une autre fonction similaire
# @param instance : toujours la meme instance
# @param size : la taille de l'interval (cf au dessus si tu comprends pas)
# @return Array{Int64,1} : une position aleatoire t'as tout compris
function similar(instance::Array{Array{Int64,1},1},size::Int64)
    ## faire suivant les options ??
    while true
        a = rand(1:size,2)
        for i in 3:instance[a[1]]-1
            if instance[a[1]][i]==instance[a[2]][i]
                return a
            end
        end
    end
end



# Fonction qui permet pas mal de chose mais si tu as scroller jusque là va donc mettre ta fonction et ça passe :)
# @param instance : toujours la meme instance
# @param size : la taille de l'interval (cf au dessus si tu comprends pas)
# @return Array{Int64,1} : une position aleatoire toujours
function consecutive(instance::Array{Array{Int64,1},1},size::Int64)
    k=rand(1:size,1)
    return [k,k+1]
end



## faudra faire un array des violation ??? un truc comme ça ou alors mettre dans instnace si l est en violation bref caca
function denominator(instance::Array{Array{Int64,1},1},ratio::Array{Array{Int64,1},1},sz::Int64)
    k= rand(1:sz,1)
    q = rand(1:size(ratio)[1],1)

    return [k,k[1]+ratio[q][1][2]]
end



# Fonction
function same_color(instance::Array{Array{Int64,1},1},size::Int64)
    ## faire suivant les options ??
    while true
        a = rand(1:size,2)
        if instance[a[1]][2]==instance[a[2]][2]&& a!=b
            return a
        end
    end
end



## on met dans instance le block de meme couleur.
function border_block_one(instance::Array{Array{Int64,1},1},size::Int64)
    a = rand(1:size,1)
    r = rand(1)
    if r >0.5
        k =instance[a][size-2]
    else
        k =instance[a][size-1]
    end
    l = rand(1:size,1)
    return [k,l[1]]
end



## la meme
function border_block_two(instance::Array{Array{Int64,1},1},sz::Int64)
    sz = size(instance[1])[1]
    a = same_color(instance,sz)
    r = rand(1)

    if r[1] >0.5
        k =instance[a[1]][sz-2]
    else
        k =instance[a[1]][sz-1]
    end

    r = rand(1)

    if r[1] >0.5
        l =instance[a[2]][sz-2]
    else
        l =instance[a[2]][sz-1]
    end

    if k==l
        return [instance[a[2]][sz-2],instance[a[2]][sz-1]]
    end

    return [k,l]
end



## faudra faire un array des violation ??? un truc comme ça ou alors mettre dans instnace si l est en violation bref caca
function violation(instance::Array{Array{Int64,1},1},prio::Array{Array{Int64,1},1},size::Int64)
    l = rand(1:size,1)

    while true
        k = rand(1:size,1)
        if prio[k][1]>0
            return [k,l]
        end
    end
end



## nique ta mere
function violation_same_color(instance::Array{Array{Int64,1},1},prio::Array{Array{Int64,1},1},size::Int64)
    k = rand(1:size,1)

    while prio[k][1]==0
        k = rand(1:size,1)
    end

    while true
        l = rand(1:size,1)
        if instance[k[1]][2]==instance[l[1]][2]
            return [k,l]
        end
    end
end


#<<<<<<< HEAD:Src/Metaheuristique/fonction_rand.jl
generic(Int64(1000))
generic(Int64(1000))
#=======#
#generic(1000)
#generic(1000)
#>>>>>>> cd0c5387709701f01f4d74d5c590f33dcb6fdc95:Src/Util/fonction_rand.jl
