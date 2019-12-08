


function global_mouvement_3!(LSfoo!::Symbol, sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}} , Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol,score::Array{Int,1},score_nadir::Array{Int,1})
    if    LSfoo! == :reflection! && k>25 && l-k>1 && l<size(sequence_courante)[1]-25
        return @eval reflection_3!($sequence_courante, $k, $l, $ratio_option, $tab_violation , $Hprio, $obj, $pbl, :rand_mov,$score,$score_nadir)
    elseif LSfoo! == :shuffle!
         #return @eval shuffle_3!($sequence_courante, $k, $l, $ratio_option, $tab_violation , $Hprio, $obj, $pbl, :rand_mov,$score,$score_nadir)
    elseif LSfoo! == :swap!
        return @eval swap_3!($sequence_courante, $k, $l, $ratio_option, $tab_violation , $Hprio, $obj, $pbl, :rand_mov,$score,$score_nadir)
    elseif LSfoo! == :insertion! && k>20 && l-k>1 && l<size(sequence_courante)[1]-20
        return @eval insertion_3!($sequence_courante, $k, $l, $ratio_option, $tab_violation , $Hprio, $obj, $pbl, :rand_mov,$score,$score_nadir)
    end
    return false
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
function reflection_3!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}} , Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol,score::Array{Int,1},score_nadir::Array{Int,1})
    sz = size(sequence_courante)[1]
    cond = false
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    cond = eval_pbl_reflection(sequence_courante ,pbl,k,l)
    if !cond
        return false
    end
    cond = false
    tmp_color = eval_couleur_reflection(sequence_courante,pbl,k,l)

    tmp_Hprio = eval_Hprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)

    tmp_Lprio = eval_Lprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)

    cond = (tmp_color<0 || tmp_Hprio<0 || tmp_Lprio<0) && (score[3]+tmp_Lprio<score_nadir[3] || score[2]+tmp_Hprio<score_nadir[2] || score[1]+tmp_color<score_nadir[1])
    if cond
        tmp = [i for i in (k):(l)]
        tmp =reverse(tmp)
        update_col_seq_reflection(sequence_courante,ratio_option,pbl,k,l)
        update_tab_violation_reflection(sequence_courante,ratio_option,tab_violation,tmp,Hprio,pbl,k,l)
        reverse!(sequence_courante,k,l)
        update_col_and_pbl_reflection(sequence_courante,ratio_option,pbl,k,l)
        score[1]+=tmp_color
        score[2]+=tmp_Hprio
        score[3]+=tmp_Lprio
        return true
    else
        return false
    end
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
function swap_3!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}} , Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol,score::Array{Int,1},score_nadir::Array{Int,1})
    # Realisation du benefice ou non du mvt
    szcar =size(sequence_courante[1])[1]
    cond = false
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    cond = eval_pbl_swap(sequence_courante, pbl, k, l)
    if !cond
        return false
    end
    cond = false
    tmp_color = eval_couleur_swap(sequence_courante, pbl, k, l)

    tmp_Hprio = eval_Hprio_swap(sequence_courante, ratio_option, tab_violation, Hprio, k, l)

    tmp_Lprio = eval_Lprio_swap(sequence_courante,ratio_option,tab_violation,Hprio,k,l)


    cond = (tmp_color<0 || tmp_Hprio<0 || tmp_Lprio<0) && (score[3]+tmp_Lprio<score_nadir[3] || score[2]+tmp_Hprio<score_nadir[2] || score[1]+tmp_color<score_nadir[1])
    if cond
        tmp=copy(sequence_courante[k])
        sequence_courante[k]=sequence_courante[l]
        sequence_courante[l]=tmp
        update_tab_violation_and_pbl_swap!(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
        score[1]+=tmp_color
        score[2]+=tmp_Hprio
        score[3]+=tmp_Lprio
        return true
    else
        return false
    end
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
function shuffle_3!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1} , Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol,score::Array{Int,1},score_nadir::Array{Int,1})
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
    cond = eval_pbl_shuffle(sequence_courante,seq,pbl,k,l)
    if !cond
        return false
    end
    tmp_Hprio = 0
    tmp_Lprio =0
    cond = false
    tmp_color = eval_couleur_shuffle(sequence_courante,seq,pbl,k,l)

    tmp_Hprio = eval_Hprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)

    tmp_Lprio = eval_Lprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)


    cond = (tmp_color<0 || tmp_Hprio<0 || tmp_Lprio<0) && (score[3]+tmp_Lprio<score_nadir[3] || score[2]+tmp_Hprio<score_nadir[2] || score[1]+tmp_color<score_nadir[1])
    if cond
        update_tab_violation_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
        splice!(sequence_courante,(k):(l+k-1),sequence_courante[seq])
        update_col_and_pbl_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
        score[1]+=tmp_color
        score[2]+=tmp_Hprio
        score[3]+=tmp_Lprio
        return true
    else
        return false
    end
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
function insertion_3!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}} , Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol,score::Array{Int,1},score_nadir::Array{Int,1})
    if k > l # Gestion du cas ou s'est inversé. Cette solution n'est surement pas top
        tmp = l
        l = k
        k = tmp
    end
    szcar =size(sequence_courante[1])[1]
    cond = false
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    cond = eval_pbl_fi_insertion(sequence_courante ,pbl,k,l)
    if !cond
        return false
    end
    tmp_color = eval_couleur_fi(sequence_courante, pbl, k, l)

    tmp_Hprio = eval_Hprio_fi(sequence_courante, ratio_option, tab_violation, Hprio, k, l)

    tmp_Lprio = eval_Lprio_fi(sequence_courante,ratio_option,tab_violation,Hprio,k,l)


    cond = (tmp_color<0 || tmp_Hprio<0 || tmp_Lprio<0) && (score[3]+tmp_Lprio<score_nadir[3] || score[2]+tmp_Hprio<score_nadir[2] || score[1]+tmp_color<score_nadir[1])
    if cond
        seq = [i for i in k:l-1]
        prepend!(seq,l)
        update_tab_violation_fi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
        splice!(sequence_courante,(k):(l),sequence_courante[seq])
        # Mise à jour du tableau de violation et pbl :
        update_col_and_pbl_fi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
        score[1]+=tmp_color
        score[2]+=tmp_Hprio
        score[3]+=tmp_Lprio
        return true
    else
        return false
    end
end
