using Random
Random.seed!(0)

function generic(size::Int32)

    a = rand(1:size,2)

    return a

end

function similar(instance::Array{Array{Int32,1},1},size::Int32)


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

function consecutive(instance::Array{Array{Int32,1},1},size::Int32)
    k=rand(1:size,1)
    return [k,k+1]

end
## faudra faire un array des violation ??? un truc comme ça ou alors mettre dans instnace si l est en violation bref caca
function denominator(instance::Array{Array{Int32,1},1},ratio::Array{Array{Int32,1},1},sz::Int32)


    k= rand(1:sz,1)
    q = rand(1:size(ratio)[1],1)

    return [k,k[1]+ratio[q][1][2]]

end

function same_color(instance::Array{Array{Int32,1},1},size::Int32)


    ## faire suivant les options ??
    while true
        a = rand(1:size,2)
        if instance[a[1]][2]==instance[a[2]][2]&& a!=b
            return a
        end

    end

end
## on met dans instance le block de meme couleur.
function border_block_one(instance::Array{Array{Int32,1},1},size::Int32)
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
function border_block_two(instance::Array{Array{Int32,1},1},sz::Int32)
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
function violation(instance::Array{Array{Int32,1},1},prio::Array{Array{Int32,1},1},size::Int32)
    l = rand(1:size,1)

    while true
        k = rand(1:size,1)
        if prio[k][1]>0
            return [k,l]
        end
    end
end

## nique ta mere
function violation_same_color(instance::Array{Array{Int32,1},1},prio::Array{Array{Int32,1},1},size::Int32)
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


generic(1000)
generic(1000)
