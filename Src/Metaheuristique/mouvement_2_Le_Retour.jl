# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 3




# Fonction qui fait appelle à la bonne fonction de mouvement pour la recherche d'une solution ameliorante avec tout les obj atcifs
# @param LSfoo!::Function : LSfoo! doit etre une des fonctions de recherche locale (swap!, fw_insertion!, bw_insertion!, reflection!, permutation!). Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @param sz : le nombre de vehicules
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
function global_mouvement_2!(LSfoo!::Symbol, sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    if    LSfoo! == :reflection!
        return @eval reflection_2!($sequence_courante, $k, $l, $ratio_option, $tab_violation, $col_avant, $Hprio, $obj, $pbl, :rand_mov)
    elseif LSfoo! == :shuffle!
        return @eval shuffle_2!($sequence_courante, $k, $l, $ratio_option, $tab_violation, $col_avant, $Hprio, $obj, $pbl, :rand_mov)
    elseif LSfoo! == :swap!
        return @eval swap_2!($sequence_courante, $k, $l, $ratio_option, $tab_violation, $col_avant, $Hprio, $obj, $pbl, :rand_mov)
    elseif LSfoo! == :insertion! && k>20 && l-k>1 && l<size(sequence_courante)[1]-20
        return @eval insertion_2!($sequence_courante, $k, $l, $ratio_option, $tab_violation, $col_avant, $Hprio, $obj, $pbl, :rand_mov)
    end

    return false
    nothing
end


# Fonction principale du mouvement_2 de reflection
# @param sequence_courante : la sequence ou instance courante
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
function reflection_2!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    sz = size(sequence_courante)[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    tmp_color = eval_couleur_reflection(sequence_courante,col_avant,pbl,k,l)
    if tmp_color>0
        return false
    end
    tmp_Hprio = eval_Hprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
    if tmp_Hprio>0
        return false
    end

    tmp_Lprio = eval_Lprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
    if tmp_Lprio>0
        return false
    end

    tmp = [i for i in (k):(l)]
    tmp =reverse(tmp)
    update_col_seq_reflection(sequence_courante,ratio_option,pbl,k,l)
    update_tab_violation_reflection(sequence_courante,ratio_option,tab_violation,tmp,Hprio,pbl,k,l)
    reverse!(sequence_courante,k,l)
    update_col_and_pbl_reflection(sequence_courante,ratio_option,pbl,k,l)

    return true

    nothing # Pas de return pour eviter les copies de memoire.
end

# Fonction principale du mouvement de swap
# @param sequence_courante : la sequence ou instance courante
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
function swap_2!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    # Realisation du benefice ou non du mvt
    szcar =size(sequence_courante[1])[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    tmp_color = eval_couleur_swap(sequence_courante,col_avant, pbl, k, l)
    if tmp_color>0
        return false
    end
    tmp_Hprio = eval_Hprio_swap(sequence_courante, ratio_option, tab_violation, Hprio, k, l)
    if tmp_Hprio>0
        return false
    end
    tmp_Lprio = eval_Lprio_swap(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
    if tmp_Lprio>0
        return false
    end


    tmp=copy(sequence_courante[k])
    sequence_courante[k]=sequence_courante[l]
    sequence_courante[l]=tmp
    update_tab_violation_and_pbl_swap!(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    return true


    nothing # Pas de return pour eviter les copies de memoire.
end


# Fonction principale du mouvement de shuffle
# @param sequence_courante : la sequence ou instance courante
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
function shuffle_2!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    sz = size(sequence_courante)[1]
    if pbl >10
        l = rand(10:15,1)[1]
    else
        l = rand(10:pbl,1)[1]
    end

    k = rand(1:sz-l,1)[1]

    ## shuffle un array ça existe 100%
    rng = MersenneTwister(3);
    seq =randperm(rng,l)

    for i in 1:l
        seq[i]+=k-1
    end

    cond_no = true
    cond_ui =false
    #aa , b =evaluation_init(sequence_courante,ratio_option,Hprio)
    tmp_Hprio = 0
    tmp_Lprio =0

    tmp_color = eval_couleur_shuffle(sequence_courante,seq,pbl,k,l)
    if tmp_color>0
        return false
    end
    tmp_Hprio = eval_Hprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)
    if tmp_Hprio>0
        return false
    end
    tmp_Lprio = eval_Lprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)
    if tmp_Lprio>0
        return false
    end

    update_tab_violation_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l+k-1),sequence_courante[seq])
    update_col_and_pbl_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
    return true


    nothing # Pas de return pour eviter les copies de memoire.
end

# Fonction principale du mouvement de forward insertion
# @param sequence_courante : la sequence ou instance courante
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
function insertion_2!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    if k > l # Gestion du cas ou s'est inversé. Cette solution n'est surement pas top
        tmp = l
        l = k
        k = tmp
    end
    # Realisation du benefice ou non du mvt
    szcar =size(sequence_courante[1])[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0

    tmp_color = eval_couleur_fi(sequence_courante, pbl, k, l)
    if tmp_color>0
        return false
    end
    tmp_Hprio = eval_Hprio_fi(sequence_courante, ratio_option, tab_violation, Hprio, k, l)

    if tmp_Hprio>0
        return false
    end
    tmp_Lprio = eval_Lprio_fi(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
    if tmp_Lprio>0
        return false
    end

    # Sinon on realise le mouvement de fw :

    seq = [i for i in k:l-1]
    prepend!(seq,l)
    update_tab_violation_fi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l),sequence_courante[seq])
    # Mise à jour du tableau de violation et pbl :
    update_col_and_pbl_fi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    return true
    nothing
end
