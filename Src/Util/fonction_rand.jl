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



# Fonction qui permet selon le type pré def de générer le k et l desiré
# @param sequence_meilleure : La sequence actuelle
# @param ratio_option : le tableau des ratios
# @param tab_violation : le tableau de violation
# @param S : Le type de generation
# @param Phase : la phase courante
# @param obj : le tab des val sur fonc obj
# @param Hprio : le nombre de hprio
# @return ::Int : la valeur du premier indice (k)
# @return ::Int : la valeur du second indice (l)
function  choose_f_rand(sequence_meilleure::Array{Array{Int,1},1}, ratio_option::Array{Array{Int,1},1}, tab_violation::Array{Array{Int,1},1}, S::Symbol, Phase::Int, obj::Array{Int,1}, Hprio::Int)
    sz = size(sequence_meilleure)[1]
    if S==:generic!
        tmp = generic(sz)
    elseif S== :denominator!
        tmp = denominator(sequence_meilleure,ratio_option,sz)
    elseif S== :same_color!
          tmp = same_color(sequence_meilleure,sz)
    elseif S== :consecutive!
          tmp = consecutive(sequence_meilleure,sz)
    elseif S==  :border_block_one!
          tmp = border_block_one(sequence_meilleure,sz)
    elseif S==  :border_block_two!
          tmp = border_block_two(sequence_meilleure,sz)
    elseif S==  :similar!
          tmp = similar(sequence_meilleure,ratio_option,sz,Hprio,obj,Phase)
    elseif S==  :violation!
          tmp = violation(sequence_meilleure,ratio_option,tab_violation,sz,Hprio,obj,Phase)
    elseif S==  :violation_same_color!
          tmp = violation_same_color(sequence_meilleure,ratio_option,tab_violation,sz,Hprio,obj,Phase)
    end
      k = max(1,minimum(tmp))
      l = min(sz,maximum(tmp))
      return k,l
end



# Fonction avec un nom generic
# @param size : la taille max
# @return Array{Int32,1} : une position aleatoire
function generic(size::Int32)
    a = rand(1:size,2)
    return a
end



# Une autre fonction similaire
# @param instance : toujours la meme instance
# @param size : la taille de l'interval (cf au dessus si tu comprends pas)
# @return Array{Int32,1} : une position aleatoire t'as tout compris
function similar(instance::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},sz::Int,Hprio::Int,obj::Array{Int,1},Phase::Int)
    if Phase ==1 ||(Phase==2 && obj[2]==2)
        while true
            a = rand(1:sz,2)
            for i in 3:Hprio
                if instance[a[1]][i]==instance[a[2]][i]
                    return a
                end
            end
        end
    else
        while true
            a = rand(1:sz,2)
            for i in 3:size(ratio_option)[1]+2
                if instance[a[1]][i]==instance[a[2]][i]
                    return a
                end
            end
        end
    end

end



# Fonction qui permet pas mal de chose mais si tu as scroller jusque là va donc mettre ta fonction et ça passe :)
# @param instance : toujours la meme instance
# @param size : la taille de l'interval (cf au dessus si tu comprends pas)
# @return Array{Int32,1} : une position aleatoire toujours
function consecutive(instance::Array{Array{Int,1},1},sz::Int)
    k=rand(1:sz-1,1)[1]
    return [k,k+1]
end



## faudra faire un array des violation ??? un truc comme ça ou alors mettre dans instnace si l est en violation bref caca
function denominator(instance::Array{Array{Int,1},1}, ratio::Array{Array{Int,1},1}, sz::Int)
    k= rand(1:sz,1)[1]
    q = rand(1:size(ratio)[1],1)[1]

    return [k,k[1]+ratio[q][2]]
end



# Fonction
function same_color(instance::Array{Array{Int,1},1},size::Int)
    while true
        a = rand(1:size,2)
        if instance[a[1]][2]==instance[a[2]][2]&& a[1]!=a[2]
            return a
        end
    end
end



## on met dans instance le block de meme couleur.
function border_block_one(instance::Array{Array{Int,1},1},sz::Int)
    szcar = size(instance[1])[1]
    a = rand(1:sz,1)[1]
    r = rand(1)[1]
    if r >0.5
        k =instance[a][szcar-2]
    else
        k =instance[a][szcar-1]
    end
    l = rand(1:sz,1)[1]
    return [k,l[1]]
end



## la meme
function border_block_two(instance::Array{Array{Int,1},1},sz::Int)
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
function violation(instance::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},sz::Int,Hprio::Int,obj::Array{Int,1},Phase::Int)
    tmpi = 1000
    if Phase ==1 ||(Phase==2 && obj[2]==2)
        #=a, b =evaluation_init(instance,ratio_option,Hprio)
        if(a[2]==0)
            return rand(1:sz,2)
        end=#
        l = rand(1:sz,1)[1]
        tmpi+=1
        while true && tmpi<size(instance)[1]
            tmpi+=1
            k = rand(1:sz,1)[1]
            for i in 1:Hprio
                if tab_violation[k][i]>0 && l!=k
                    return [k,l]
                end
            end
        end
    else
        l = rand(1:sz,1)[1]
        #=a, b =evaluation_init(instance,ratio_option,Hprio)
        if(a[2]==0 &&a[3]==0)
            return rand(1:sz,2)
        end=#
        while true && tmpi<size(instance)[1]
            tmpi+=1
            k = rand(1:sz,1)[1]
            for i in 1:size(ratio_option)[1]
                if tab_violation[k][i]>0 && l!=k
                    return [k,l]
                end
            end
        end
    end
    return generic(sz)

end


function violation_same_color(instance::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},sz::Int,Hprio::Int,obj::Array{Int,1},Phase::Int)
    #=a, b =evaluation_init(instance,ratio_option,Hprio)
    if(a[2]==0)
        return rand(1:sz,2)
    end=#
    tmpi = 1000
    while true && tmpi<size(instance)[1]

        tmp = rand(1:sz,2)
        k =tmp[1]
        l = tmp[2]
        cond = false
        tmpi+=1
        if l!=k && instance[l][2]==instance[k][2]
            for i in 1:size(ratio_option)[1]
                if tab_violation[l][i]>0
                    cond = true
                end
            end
            if cond
                cond = false
                for i in 1:size(ratio_option)[1]
                    if tab_violation[k][i]>0
                        cond = true
                    end
                end
            end
            if cond
                return k,l
            end
        end
    end
    return same_color(instance,sz)
end
