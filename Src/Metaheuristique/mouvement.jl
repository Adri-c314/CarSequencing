# Fichier tous les algorithms gloutons et leurs foncions associées
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 3




# Fonction qui fait appelle à la bonne fonction de mouvement
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
function global_mouvement!(LSfoo!::Symbol, sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    if LSfoo! == :insertion! || LSfoo! == :swap! || LSfoo! == :reflection! || LSfoo! == :shuffle!
        return @eval $LSfoo!($sequence_courante, $k, $l, $ratio_option, $tab_violation, $col_avant, $Hprio, $obj, $pbl, :rand_mov)
    end
    return false
    nothing
end




# =====================================================================
# =========                insertions                   ===============
# =====================================================================

# Fonction principale du mouvement d'insertion de maniere random entre bw et fw
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
function insertion!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)

    if k>l
        tmpl = l
        l = k
        k =tmpl
    end
    if k>20 && k!=l && l-k>1 && l<size(sequence_courante)[1]-20

        return fw_insertion!(sequence_courante, k, l, ratio_option, tab_violation, Hprio, obj, pbl, rand_mov)
        if rand(2:2) == 1
            #return fw_insertion!(sequence_courante, k, l, ratio_option, tab_violation, Hprio, obj, pbl, rand_mov)
        else
            #return bw_insertion!(sequence_courante, k, l, ratio_option, tab_violation, Hprio, obj, pbl, rand_mov)
        end
    end
    return false
    nothing
end



# Fonction principale du mouvement de backward insertion
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
function bw_insertion!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    # Realisation du benefice ou non du mvt
    szcar =size(sequence_courante[1])[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0

    for o in obj
        if o==1 #&& (rand_mov!=:border_block_two! ||rand_mov!=:same_color!||rand_mov!=:violation_same_color!)
            tmp_color = eval_couleur_bi(sequence_courante, pbl, k, l)
            cond = tmp_color<=0
            if tmp_color<0
                break
            end
        elseif o==2
            tmp_Hprio = eval_Hprio_bi(sequence_courante, ratio_option, tab_violation, Hprio, k, l)
            cond = tmp_Hprio <=0
            if tmp_Hprio<0
                break
            end
        elseif o==3
            tmp_Lprio = eval_Lprio_bi(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
            if tmp_Lprio<0
                break
            end
        end
        # Si ça n'ameliore pas alors on fait rien
        if !cond
            return false
        end
    end
    ###println(tab_violation)
    # Sinon on realise le mouvement de bw :
    if k > l # Gestion du cas ou s'est inversé. Cette solution n'est surement pas top
        tmp = l
        l = k
        k = tmp
    end
    tmp = copy(sequence_courante[k])
    for i in k:l-1
        sequence_courante[i] = sequence_courante[i+1]
    end
    sequence_courante[l] = tmp

    ###println(sequence_courante)
    ##println("bw" ,k, "+",l)
    # Mise à jour du tableau de violation et pbl :
    update_tab_violation_bi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    update_col_and_pbl_bi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    ###println(tab_violation)
    ##println(sequence_courante)
    return true
    nothing
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
function fw_insertion!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    # Realisation du benefice ou non du mvt
    szcar =size(sequence_courante[1])[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    for o in obj
        if o==1 #&& (rand_mov!=:border_block_two! ||rand_mov!=:same_color!||rand_mov!=:violation_same_color!)
            tmp_color = eval_couleur_fi(sequence_courante, pbl, k, l)
            cond = tmp_color<=0
            if tmp_color<0
                break
            end
        elseif o==2
            tmp_Hprio = eval_Hprio_fi(sequence_courante, ratio_option, tab_violation, Hprio, k, l)
            cond = tmp_Hprio <=0
            if tmp_Hprio<0
                break
            end
        elseif o==3
            tmp_Lprio = eval_Lprio_fi(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
            if tmp_Lprio<0
                break
            end
        end
        # Si ça n'ameliore pas alors on fait rien
        if !cond
            return false
        end
    end
    # Sinon on realise le mouvement de fw :
    if k > l # Gestion du cas ou s'est inversé. Cette solution n'est surement pas top
        tmp = l
        l = k
        k = tmp
    end
    oui = sequence_courante[k][2]!=sequence_courante[l][2]
    if oui
        ###println(k)
        ###println(l)
    end
    aa =evaluation(sequence_courante,tab_violation,ratio_option,Hprio)
    seq = [i for i in k:l-1]
    prepend!(seq,l)
    update_tab_violation_fi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l),sequence_courante[seq])
    # Mise à jour du tableau de violation et pbl :
    update_col_and_pbl_fi(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    a =evaluation(sequence_courante,tab_violation,ratio_option,Hprio)
    if a[2]>aa[2]#||(a[2]==aa[2]&& a[1]>aa[1])
        println(tmp_Hprio)
        println(tmp_color)
        println(aa)
        println(a)
        for i in k-10:l+10
            println(sequence_courante[i])
        end
        println("k : ", k," l : ",l)
        return tamerepute
    end
    return true
    nothing
end

# Fonction qui evalue le nombre de Hprio violer pour la forward insertion
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return ::Int : la dif de Hprio violé
function eval_Hprio_fi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end
    #println("______________________")
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD

    for i in 1:Hprio
            #        println("k ")
        if k+ratio_option[i][2]-1<l
            tmp_viol += -tab_violation[i][l]
            #println(tmp_viol)
            #println(i)
        end
        for j in k:min(l-1,k+ratio_option[i][2]-1)

            if sequence_courante[l][i+2]!=sequence_courante[j][i+2]
                if sequence_courante[l][i+2]==1
                    if tab_violation[i][j]>=0
                        #println("i : ", i ," ui : ", j )
                        tmp_viol+=1
                    end
                end
                if sequence_courante[l][i+2]==0
                    if tab_violation[i][j]>0

                            #println("i : ", i ," non : ", j )
                        tmp_viol-=1
                    end
                end
            end
        end
        #println("l")
        for j in l+1:min(sz,l+ratio_option[i][2]-1)

            if j-ratio_option[i][2]>=k
                if sequence_courante[l][i+2]!=sequence_courante[j-ratio_option[i][2]][i+2]
                    if sequence_courante[l][i+2]==1
                        if tab_violation[i][j]>0
                            #println("i : ", i ," nonn : ", j)
                            tmp_viol-=1
                        end
                    elseif sequence_courante[l][i+2]==0
                        if tab_violation[i][j]>=0

                            #    println("i : ", i ," uii : ", j )
                            tmp_viol+=1
                        end
                    end
                end
            end
        end
    end
    return tmp_viol
end

# Fonction qui evalue le nombre de Hprio violer pour la forward insertion
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return ::Int : la dif de Hprio violé
function eval_Hprio_bi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end

    sz = size(sequence_courante)[1]
    tmp_viol=0
    for i in 1:Hprio

        #fenetres de k-ratio+1 à k
        for j in k:min(l,k+ratio_option[i][2]-1)
            if sequence_courante[k][i+2]==1 && sequence_courante[j+1][i+2]==0
                if tab_violation[i][j]>0
                    tmp_viol-=1
                end
            elseif sequence_courante[k][i+2]==0 && sequence_courante[j+1][i+2]==1
                if tab_violation[i][j]>=0
                    tmp_viol+=1
                end
            end
        end

        #fenetre de l-ratio +1 à l
        for j in l:min(sz,l+ratio_option[i][2]-1)
            if sequence_courante[k][i+2]==1 && sequence_courante[j-ratio_option[i][2]+1][i+2]==0
                if tab_violation[i][j]>=0
                    tmp_viol+=1
                end
            elseif sequence_courante[k][i+2]==0 && sequence_courante[j-ratio_option[i][2]+1][i+2]==1
                if tab_violation[i][j]>0
                    tmp_viol-=1
                end
            end
        end

    end

    return tmp_viol
end

# Fontion qui evalue la difference de RAF si on effectu la bi de k,l
# @param sequence_courante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Bool : si c'est autorisé comme changement
function eval_couleur_bi(sequence_courante::Array{Array{Int,1},1}, pbl::Int, k::Int, l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end

    sz = size(sequence_courante)[1]
    #szcar =size(sequence_courante[1])[1]
    tmp_color=0

    #Les purges qui disparaissent
    if l!=sz
        if sequence_courante[l-1][2]!=sequence_courante[l+1][2]
            tmp_color-=1
        end
    end
    if k!=1
        if sequence_courante[k-1][2]!=sequence_courante[l][2]
            tmp_color-=1
        end
    end
    if sequence_courante[l][2]!= sequence_courante[k+1][2]
        tmp_color-=1
    end

    #Les purges qu'ont ajoute
    if l!=sz
        if sequence_courante[l][2]!=sequence_courante[l+1][2]
            tmp_color+=1
        end
    end
    if sequence_courante[l-1][2]!=sequence_courante[l][2]
        tmp_color+=1
    end
    if k!=1
        if sequence_courante[k][2]!=sequence_courante[k-1][2]
            tmp_color+=1
        end
    end

    return tmp_color
end

# Fontion qui evalue la difference de RAF si on effectu le fi de k,l
# @param sequence_courante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Bool : si c'est autorisé comme changement
function eval_couleur_fi(sequence_courante::Array{Array{Int,1},1}, pbl::Int, k::Int, l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end

    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0

    #Les purges qui change en k
    if sequence_courante[l][2]==sequence_courante[k][2]
        return 0
    else
        if l<sz && sequence_courante[l][2]==sequence_courante[l-1][2] || sequence_courante[l][2]==sequence_courante[l+1][2]
            if sequence_courante[l][2]!=sequence_courante[k-1][2]
                tmp_color+=1
            end
        else
            if sequence_courante[l-1][2]!=sequence_courante[l+1][2]
                tmp_color-=1
            end
        end
    end
    return tmp_color
end

# Fonction qui evalue la difference de EP si on effectu la fi k,l
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de ENP de difference
function eval_Lprio_fi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end

    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in Hprio+1:size(ratio_option)[1]

        for j in k:min(l,k+ratio_option[i][2]-1)
            if sequence_courante[l][i+2]==1 && sequence_courante[j][i+2]==0
                if tab_violation[i][j]>=0
                    tmp_viol+=1
                end
            elseif sequence_courante[l][i+2]==0 && sequence_courante[j][i+2]==1
                if tab_violation[i][j]>0
                    tmp_viol-=1
                end
            end
        end

        for j in l+1:min(sz,l+ratio_option[i][2]-1)
            if j-ratio_option[i][2]+1>k
                if sequence_courante[l][i+2]==1 && sequence_courante[j-ratio_option[i][2]][i+2]==0
                    if tab_violation[i][j]>0
                        tmp_viol-=1
                    end
                elseif sequence_courante[l][i+2]==0 && sequence_courante[j-ratio_option[i][2]][i+2]==1
                    if tab_violation[i][j]>=0
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    return tmp_viol
end

# Fonction qui evalue la difference de EP si on effectu la bi k,l
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de ENP de difference
function eval_Lprio_bi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end

    sz = size(sequence_courante)[1]
    tmp_viol=0
    for i in Hprio+1:size(ratio_option)[1]

        #fenetres de k-ratio+1 à k
        for j in k:min(l,k+ratio_option[i][2]-1)
            if sequence_courante[k][i+2]==1 && sequence_courante[j+1][i+2]==0
                if tab_violation[i][j]>0
                    tmp_viol-=1
                end
            elseif sequence_courante[k][i+2]==0 && sequence_courante[j+1][i+2]==1
                if tab_violation[i][j]>=0
                    tmp_viol+=1
                end
            end
        end

        #fenetre de l-ratio +1 à l
        for j in l:min(sz,l+ratio_option[i][2]-1)
            if sequence_courante[k][i+2]==1 && sequence_courante[j-ratio_option[i][2]+1][i+2]==0
                if tab_violation[i][j]>=0
                    tmp_viol+=1
                end
            elseif sequence_courante[k][i+2]==0 && sequence_courante[j-ratio_option[i][2]+1][i+2]==1
                if tab_violation[i][j]>0
                    tmp_viol-=1
                end
            end
        end

    end

    return tmp_viol
end

# Fonction qui maj le tab violation de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : modifie tab_violation
function update_tab_violation_bi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]

    for i in 1:size(ratio_option)[1]
        fenetre = ratio_option[i][2]

        #ratio du début
        if k==1
            if sequence_courante[k][2+i]==0
                tab_violation[i][k]=-ratio_option[i][1]
            else sequence_courante[k][2+i]==1
                tab_violation[i][k]=-ratio_option[i][1]+1
            end
        else
            if k-fenetre+1<1
                if sequence_courante[k][2+i]==0
                    tab_violation[i][k]=tab_violation[i][k-1]
                else sequence_courante[k][2+i]==1
                    tab_violation[i][k]=tab_violation[i][k-1]+1
                end
            else
                if sequence_courante[k][2+i]==0 && sequence_courante[l][2+i]==1
                    tab_violation[i][k]=tab_violation[i][k-1]-1
                elseif sequence_courante[k][2+i]==1 && sequence_courante[l][2+i]==0
                    tab_violation[i][k]=tab_violation[i][k-1]+1
                else
                    tab_violation[i][k]=tab_violation[i][k-1]
                end
            end
        end

        for j in k+1:min(k+fenetre-2,l-1)
            if j-fenetre+1<1
                if sequence_courante[j][2+i]==0
                    tab_violation[i][j]=tab_violation[i][j-1]
                else sequence_courante[j][2+i]==1
                    tab_violation[i][j]=tab_violation[i][j-1]+1
                end
            else
                if sequence_courante[j][2+i]==0 && sequence_courante[l][2+i]==1
                    tab_violation[i][j]=tab_violation[i][j-1]-1
                elseif sequence_courante[j][2+i]==1  && sequence_courante[l][2+i]==0
                    tab_violation[i][j]=tab_violation[i][j-1]+1
                else
                    tab_violation[i][j]=tab_violation[i][j-1]
                end
            end
        end

        #On décale tous les ratios
        if k+fenetre-2<l-1
            for j in k+fenetre-1:l-1
                tab_violation[i][j] = tab_violation[i][j+1]
            end
        end

        #ratio de la fin
        for j in l:min(l+fenetre-1,sz)
            if j-fenetre+1 > 1
                if sequence_courante[l][2+i]==0 && sequence_courante[j-fenetre][2+i]==1
                    tab_violation[i][j]=tab_violation[i][j-1]-1
                elseif sequence_courante[l][2+i]==1 && sequence_courante[j-fenetre][2+i]==0
                    tab_violation[i][j]=tab_violation[i][j-1]+1
                else
                    tab_violation[i][j]=tab_violation[i][j-1]
                end
            else
                if sequence_courante[j+1][2+i]==0
                    tab_violation[i][j]=tab_violation[i][j-1]
                else sequence_courante[j+1][2+i]==1
                    tab_violation[i][j]=tab_violation[i][j-1]+1
                end
            end
        end
    end
end

# Fonction qui maj le tab violation de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : modifie tab_violation
function update_tab_violation_fi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:size(ratio_option)[1]
        tmp = tab_violation[i][min(l,k+ratio_option[i][2]-1)]
        for j in min(l,k+ratio_option[i][2]-1):l-1
            tmp2 = tab_violation[i][j+1]
            tab_violation[i][j+1] = tmp
            tmp =tmp2
        end


        for j in k:min(l-1,k+ratio_option[i][2]-1)

            if sequence_courante[l][i+2]!=sequence_courante[j][i+2]
                if sequence_courante[l][i+2]==1
                    tab_violation[i][j]+=1
                end
                if sequence_courante[l][i+2]==0
                    tab_violation[i][j]-=1
                end
            end
        end


        for j in l+1:min(sz,l+ratio_option[i][2]-1)
            if j-ratio_option[i][2]+1>k
                if sequence_courante[l][i+2]!=sequence_courante[j-ratio_option[i][2]][i+2]
                    if sequence_courante[l][i+2]==1
                        tab_violation[i][j]-=1
                    elseif sequence_courante[l][i+2]==0
                        tab_violation[i][j]+=1
                    end
                end
            end
        end
    end
end

# Fonction qui maj les color de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify sequence_courante : modifie les fenetre dans la sequence
function update_col_and_pbl_bi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,pbl::Int,k::Int,l::Int)
    if k>l
        tmp = k
        k=l
        l=tmp
    end
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]

    if sequence_courante[l][szcar-2]<=0
        ##println(sequence_courante)
    end
    #seq color: ????(k)???---------?????lk?????
    if sequence_courante[l-1][szcar-2]>k

        #bloc couleur k
        tmpDebk=sequence_courante[l][szcar-2]
        tmpFink=sequence_courante[l][szcar-1]

        #On met à jour le bloc de couleur k et le suivant (si en enlevant k on regroupe de bloc)
        if k==1
            tempDebkMoins=0
        else
            tmpDebkMoins=sequence_courante[k-1][szcar-2]
        end
        if sequence_courante[l][szcar-1]+1<=sz
            if sequence_courante[l][2]!=sequence_courante[l-1][2]
                tmpFinkPlus=min(sequence_courante[sequence_courante[l][szcar-1]+1][szcar-1],l-1)
            else
                tmpFinkPlus=sequence_courante[sequence_courante[l][szcar-1]+1][szcar-1]
            end
        else
            tmpFinkPlus=sz
        end

        #On met à jour le bloc de couleur k et le suivant (si en enlevant k on regroupe de bloc)
        #on met à jour jusqu'au bloc k+1
        if k == 1
            if tmpDebk != tmpFink
                for j in 1:tmpFink-1
                    sequence_courante[j][szcar-2]=1
                    sequence_courante[j][szcar-1]=tmpFink-1
                end
                for j in tmpFink:tmpFinkPlus-1
                    sequence_courante[j][szcar-2]=sequence_courante[j+1][szcar-2]-1
                    sequence_courante[j][szcar-1]=sequence_courante[j+1][szcar-1]-1
                end
            else
                for j in 1:tmpFinkPlus-1
                    sequence_courante[j][szcar-2]=sequence_courante[j+1][szcar-2]-1
                    sequence_courante[j][szcar-1]=sequence_courante[j+1][szcar-1]-1
                end
            end
        elseif tmpDebk == tmpFink
            if sequence_courante[k-1][2]==sequence_courante[k][2]
                for j in tmpDebkMoins:min(tmpFinkPlus-1,l-1)
                    sequence_courante[j][szcar-2]=tmpDebkMoins
                    sequence_courante[j][szcar-1]=min(tmpFinkPlus-1,l-1)
                end
                tmpFinkPlus=(tmpFinkPlus,l)
            else
                for j in k:tmpFinkPlus-1
                    sequence_courante[j][szcar-2]=sequence_courante[j+1][szcar-2]-1
                    sequence_courante[j][szcar-1]=sequence_courante[j+1][szcar-1]-1
                end
            end
        else
            for j in tmpDebk:tmpFink-1
                sequence_courante[j][szcar-1]=sequence_courante[j+1][szcar-1]-1
            end
            for j in tmpFink:tmpFinkPlus-1
                sequence_courante[j][szcar-2]=tmpFink
                sequence_courante[j][szcar-1]=tmpFinkPlus-1
            end
        end
        #On décale les blocs
        if tmpFinkPlus < l
            for j in tmpFinkPlus:l-1
                sequence_courante[j][szcar-2]=sequence_courante[j+1][szcar-2]-1
                sequence_courante[j][szcar-1]=sequence_courante[j+1][szcar-1]-1
            end
        end
        #mise à jour du bloc  position l
        if l!=sz
            if sequence_courante[l-1][2]==sequence_courante[l][2]
                for j in sequence_courante[l-1][szcar-2]-1:l
                    sequence_courante[j][szcar-1]=l
                    sequence_courante[j][szcar-2]=sequence_courante[l-1][szcar-2]-1
                end
            else
                sequence_courante[l][szcar-2]=l
                sequence_courante[l][szcar-1]=l
            end

            if sequence_courante[l+1][2]==sequence_courante[l][2]
                for j in sequence_courante[l][szcar-2]:sequence_courante[l+1][szcar-1]
                    sequence_courante[j][szcar-2]=sequence_courante[l][szcar-2]
                    sequence_courante[j][szcar-1]=sequence_courante[l+1][szcar-1]
                end
            end
        else
            if sequence_courante[l-1][2]==sequence_courante[l][2]
                for j in sequence_courante[l-1][szcar-2]:l
                    sequence_courante[j][szcar-1]=l
                    sequence_courante[j][szcar-2]=sequence_courante[l-1][szcar-2]-1
                end
            else
                sequence_courante[l][szcar-2]=l
                sequence_courante[l][szcar-1]=l
            end
        end

        #=Une autre version de cette fonciton....
        ###mise à jour jusquàa fin
        if k==1 || sequence_courante[k-1][2]==sequence_courante[k][2]
            for i in tmpDebk:tmpFink
                sequence_courante[i][szcar-1]=tmpFink
                sequence_courante[i][szcar-2]=tmpDebk
            end
        else
            for i in tmpDebk:k-1
                sequence_courante[i][szcar-1]=k-1
                sequence_courante[i][szcar-2]=tmpDebk
            end
            for i in k:tmpFink
                sequence_courante[i][szcar-1]=tmpFink
                sequence_courante[i][szcar-2]=k
            end
        end

        if sequence_courante[l-1][szcar-2]-2>1
            for i in tmpFink+1:sequence_courante[l-1][szcar-2]-2
                sequence_courante[i][szcar-2]-=1
                sequence_courante[i][szcar-1]-=1
            end
        end

        for i in max(sequence_courante[l-1][szcar-2]-1,1):l-1
            if sequence_courante[l-1][2]!=sequence_courante[l][2]
                sequence_courante[i][szcar-1]=l-1
                sequence_courante[i][szcar-2]=max(sequence_courante[i][szcar-2]-1,1)
            else
                sequence_courante[i][szcar-2]-=1
            end
        end

        if sequence_courante[l-1][2]!=sequence_courante[l][2]
            if l!=sz
                if sequence_courante[l+1][2]==sequence_courante[l][2]
                    sequence_courante[l][szcar-1]=sequence_courante[l+1][szcar-1]
                    sequence_courante[l][szcar-2]=l
                else
                    sequence_courante[l][szcar-1]=l
                    sequence_courante[l][szcar-2]=l
                end
            else
                sequence_courante[l][szcar-1]=l
                sequence_courante[l][szcar-2]=l
            end
        else
            sequence_courante[l][szcar-2]=sequence_courante[l-1][szcar-2]
            sequence_courante[l][szcar-1]=sequence_courante[l-1][szcar-1]
        end

        if l!=sz
            for i in l+1:sequence_courante[l+1][szcar-1]
                if sequence_courante[l][2]!=sequence_courante[l+1][2]
                    if sequence_courante[l+1][2]==sequence_courante[l-1][2]
                        sequence_courante[i][szcar-2]=l+1
                    end
                else
                    if sequence_courante[l-1][2]==sequence_courante[l][2]
                        sequence_courante[i][szcar-2]-=1
                    else
                        sequence_courante[i][szcar-2]=l
                    end
                end
            end
        end=#
    end
end

# Fonction qui maj les color de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify sequence_courante : modifie les fenetre dans la sequence
function update_col_and_pbl_fi(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},Hprio::Int,pbl::Int,k::Int,l::Int)
    ll = l
    l = k
    k=k+1

    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmpDebk=sequence_courante[k][szcar-2]
    tmpFink=sequence_courante[k][szcar-1]


    if tmpDebk<=l && tmpFink>=ll
        for i in tmpDebk:tmpFink
            sequence_courante[i][szcar-2]=tmpDebk
            sequence_courante[i][szcar-1]=tmpFink
        end
        return
    end
    # update des sequence de k
    if sequence_courante[k][2] == sequence_courante[l][2]
        tmpFink+=1
        tmpDebk = min(tmpDebk,l)
        for i in tmpDebk:tmpFink
            sequence_courante[i][szcar-2]=tmpDebk
            sequence_courante[i][szcar-1]=tmpFink
        end
        tmpFink+=1
    else
        #println("k : ", k)
        #println(tmpDebk)
        #println(tmpFink)
        if tmpDebk== tmpFink
            tmpDebk = k
            tmpFink = k
        else
            tmpDebk = k
            tmpFink+=1
        end

        for i in tmpDebk:tmpFink
            sequence_courante[i][szcar-2]=tmpDebk
            sequence_courante[i][szcar-1]=tmpFink
        end
        #println(sequence_courante[k])

        if sequence_courante[l][2] == sequence_courante[l-1][2]
            for i in sequence_courante[l-1][szcar-2]:l
                sequence_courante[i][szcar-1]=l
            end
            sequence_courante[l][szcar-2]=sequence_courante[l-1][szcar-2]
        else
            sequence_courante[l][szcar-2]=l
            sequence_courante[l][szcar-1]=l
            for i in sequence_courante[l-1][szcar-2]:l-1
                sequence_courante[i][szcar-1]=l-1
            end
        end
        #println(sequence_courante[k])

        tmpFink+=1
    end
    # update des sequences de l
    tmpDebl=sequence_courante[ll][szcar-2]
    tmpFinl=sequence_courante[ll][szcar-1]
    #println( sequence_courante[k])
    #println( sequence_courante[ll])
    if sequence_courante[k][szcar-2] != sequence_courante[ll][szcar-2] || sequence_courante[k][2]!=sequence_courante[ll][2]
        #println("ui")
        if sequence_courante[ll][2] == sequence_courante[ll+1][2]
            tmpDebl=sequence_courante[ll][szcar-2]+1
            tmpFinl=sequence_courante[ll+1][szcar-1]
            for i in tmpDebl:tmpFinl
                sequence_courante[i][szcar-2]=tmpDebl
                sequence_courante[i][szcar-1]=tmpFinl
            end
        else
            #println(tmpDebl)
            if sequence_courante[l][2] == sequence_courante[ll+1][2]
                tmpDebl=ll+1
                tmpFinl=sequence_courante[ll+1][szcar-1]
                for i in tmpDebl:tmpFinl
                    sequence_courante[i][szcar-2]=tmpDebl
                end
            end
            tmpDebl=sequence_courante[ll][szcar-2]+1

            tmpFinl=ll
            for i in tmpDebl:tmpFinl
                sequence_courante[i][szcar-2]=tmpDebl
                sequence_courante[i][szcar-1]=tmpFinl
            end
        end
    else
        #println("non")
        if sequence_courante[ll][2] == sequence_courante[ll+1][2]
            tmpFinl=sequence_courante[ll+1][szcar-1]
            tmpDebl=sequence_courante[ll][szcar-2]
            for i in tmpDebl:tmpFinl
                ##println("i : ", i)
                sequence_courante[i][szcar-2]=tmpDebl
                sequence_courante[i][szcar-1]=tmpFinl
                ##println(sequence_courante[i])
            end
        else
            #println("la")
            #println(sequence_courante[ll])
            tmpFinl= ll
            tmpDebl=sequence_courante[ll][szcar-2]
            for i in tmpDebl:tmpFinl
                ##println("i : ", i)
                sequence_courante[i][szcar-2]=tmpDebl
                sequence_courante[i][szcar-1]=tmpFinl
                ##println(sequence_courante[i])
            end
            if sequence_courante[l][2] == sequence_courante[ll+1][2]
                tmpFinl=sequence_courante[ll+1][szcar-1]
                tmpDebl=sequence_courante[ll+1][szcar-2]+1
                for i in ll+1:tmpFinl
                    ##println("i : ", i)
                    sequence_courante[i][szcar-2]=tmpDebl
                    sequence_courante[i][szcar-1]=tmpFinl
                    ##println(sequence_courante[i])
                end
            end
        end

    end
    #println(sequence_courante[358])
    tmpD = sequence_courante[k][szcar-1]+1
    tmpF = sequence_courante[ll][szcar-2]-1
    #println(tmpD)
    #println(tmpF)
    for i in tmpD:tmpF
        sequence_courante[i][szcar-2]+=1
        sequence_courante[i][szcar-1]+=1
    end
end





# =====================================================================
# ====================           reflection         ===================
# =====================================================================

# Fonction principale du mouvement de reflection
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
function reflection!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    if l-k<=1
        return swap!(sequence_courante, k, l, ratio_option, tab_violation, col_avant, Hprio, obj, pbl, :rand_mov)
    end

    szcar = size(sequence_courante[1])[1]
    sz = size(sequence_courante)[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    cond = eval_pbl_reflection(sequence_courante,col_avant,pbl,k,l)
    if !cond
        return false
    end
    for o in obj
        if     o==1
            tmp_color = eval_couleur_reflection(sequence_courante,col_avant,pbl,k,l)
            cond = tmp_color<=0
            if tmp_color<0
                break
            end
        elseif o==2
            tmp_Hprio = eval_Hprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Hprio <=0
            if tmp_Hprio<0
                break
            end
        elseif o==3
            tmp_Lprio = eval_Lprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
            if tmp_Lprio<0
                break
            end
        end
        if !cond
            return false
        end
    end
    tmp = [i for i in (k):(l)]
    tmp =reverse(tmp)


    #update_col_seq_reflection(sequence_courante,ratio_option,pbl,k,l)
    update_tab_violation_reflection(sequence_courante,ratio_option,tab_violation,tmp,Hprio,pbl,k,l)
    reverse!(sequence_courante,k,l)
    update_col_and_pbl_reflection(sequence_courante,ratio_option,pbl,k,l)
    return true

    nothing # Pas de return pour eviter les copies de memoire.
end

function update_col_seq_reflection(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    if k>1&&sequence_courante[k][szcar-1]==k
        tmpk=k-1
        col = sequence_courante[k][2]
        while tmpk>=1 && sequence_courante[tmpk][2]==col
            sequence_courante[tmpk][szcar-1]=k-1
            tmpk-=1
        end
    end
    if l<sz && sequence_courante[l][szcar-2]==l
        tmpk=l+1
        col = sequence_courante[l][2]
        while tmpk<=sz && sequence_courante[tmpk][2]==col
            sequence_courante[tmpk][szcar-2]=l+1
            tmpk+=1
        end
    end
end

# Fonction qui maj le tab violation de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : modifie tab_violation
function update_tab_violation_reflection(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},sequence::Array{Int,1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0
    for i in 1:size(ratio_option)[1]
        tab_deb=[0 for i in 1:ratio_option[i][2]-1]
        tab_fin=[0 for i in 1:ratio_option[i][2]-1]
        for j in 0:min(l-k-1,ratio_option[i][2]-2,sz-k)

            if sequence_courante[min(sz,k+j)][i+2]!=sequence_courante[max(1,l-j)][i+2]
                if sequence_courante[k+j][i+2]==1
                    tab_fin[j+1]+=1
                    tab_deb[j+1]-=1
                elseif sequence_courante[max(1,l-j)][i+2]==1
                    tab_fin[j+1]-=1
                    tab_deb[j+1]+=1
                end
            end
            if j>0
                tab_fin[j+1]+=tab_fin[j]
                tab_deb[j+1]+=tab_deb[j]
            end
            tab_violation[i][k+j] += tab_deb[j+1]
            if (l-j+ratio_option[i][2]-1<=sz)
                tab_violation[i][l-j+ratio_option[i][2]-1] += tab_fin[j+1]
                tmp_viol+=max(0,tab_violation[i][l-j+ratio_option[i][2]-1])
            end
            tmp_viol+=max(0,tab_violation[i][k+j])
        end
    end
    for i in 1:size(ratio_option)[1]
            if l-k >ratio_option[i][2]-1
            reverse!(tab_violation[i],k+ratio_option[i][2]-1,l)
        end
    end
    return
end

# Fonction qui reevalue les color de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
function eval_couleur_reflection(sequence_courante::Array{Array{Int,1},1},col_avant::Tuple{Int32,Int32},pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return tmp_color
    end
    if l<sz
        if sequence_courante[k][2]==sequence_courante[l+1][2]
            tmp_color-=1
        elseif sequence_courante[l][2]==sequence_courante[l+1][2]
            tmp_color+=1
        end
    end
    if k>1
        if sequence_courante[l][2]==sequence_courante[k-1][2]
            tmp_color-=1
        elseif sequence_courante[k][2]==sequence_courante[k-1][2]
            tmp_color+=1
        end
    else
        if sequence_courante[l][2]==col_avant[2]
            tmp_color-=1
        end
        if sequence_courante[k][2]==col_avant[2]
            tmp_color+=1
        end
    end
    return tmp_color
end

# Fonction qui verifie que la nouvelle sequeence est admissible
# @param sequence_courante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
function eval_pbl_reflection(sequence_courante::Array{Array{Int,1},1},col_avant::Tuple{Int32,Int32},pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]

        if sequence_courante[k][szcar-2]==sequence_courante[l][szcar-2]
            return true
        end

        if (k-sequence_courante[k][szcar-2]+1)+(l-sequence_courante[l][szcar-2]+1)>pbl
            return false
        end
        if (sequence_courante[k][szcar-1]-k+1)+(sequence_courante[l][szcar-1]-l+1)>pbl
            return false
        end

    else
        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                if (sequence_courante[l+1][szcar-1]-(l+1)+1)+(sequence_courante[k][szcar-1]-k+1)>pbl
                    return false
                end
            end
        end
        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                if (k-1-sequence_courante[k-1][szcar-2]+1)+(l-sequence_courante[l][szcar-2]+1)>pbl
                    return false
                end
            end
        else
            if sequence_courante[l][2]==col_avant[2]
                if (col_avant[1])+(l-sequence_courante[l][szcar-2]+1)>pbl
                    return false
                end
            end
        end
    end

    return true
end

# Fonction qui maj les color de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify sequence_courante : modifie les fenetre dans la sequence
function update_col_and_pbl_reflection(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]

    if sequence_courante[k][szcar-2]!=sequence_courante[l][szcar-2]
        if k>1 && sequence_courante[k][2] == sequence_courante[k-1][2]
            tmpfin = l-sequence_courante[k][szcar - 2]+k
            for i in sequence_courante[k-1][szcar-2]:tmpfin
                sequence_courante[i][szcar-2] = sequence_courante[k-1][szcar-2]
                sequence_courante[i][szcar-1] = tmpfin
            end
            debk = sequence_courante[k][szcar-1]+1
        else
            if k>1
                for i in sequence_courante[k-1][szcar-2]:k-1
                    sequence_courante[i][szcar-2] = sequence_courante[k-1][szcar-2]
                    sequence_courante[i][szcar-1] = k-1
                end
            end
            debk = k
        end
        if l<sz && sequence_courante[l][2] == sequence_courante[l+1][2]
            tmpdeb = k-sequence_courante[l][szcar - 1]+l
            for i in tmpdeb:sequence_courante[l+1][szcar-1]
                sequence_courante[i][szcar-2] = tmpdeb
                sequence_courante[i][szcar-1] = sequence_courante[l+1][szcar-1]
            end
            finl = sequence_courante[l][szcar-2]-1
        else
            if l<sz
                for i in l+1:sequence_courante[l+1][szcar-1]
                    sequence_courante[i][szcar-2] = l+1
                    sequence_courante[i][szcar-1] = sequence_courante[l+1][szcar-1]
                end
            end
            finl = l
        end
    else
        debk=sequence_courante[k][szcar-2]
        finl=sequence_courante[k][szcar-1]
    end

    finseq = min(sz,finl)
    deb = debk
    col=sequence_courante[debk][2]
    for i in debk:finl
        if sequence_courante[i][2]!= col
            col=sequence_courante[i][2]
            deb = i
        end
        sequence_courante[i][szcar-2]=deb
    end

    tmpi = finl
    fin = finl
    col=sequence_courante[finl][2]
    for i in debk:finl
        if tmpi>=1 &&sequence_courante[tmpi][2]!= col
            col=sequence_courante[tmpi][2]
            fin = tmpi
        end

        sequence_courante[tmpi][szcar-1]=fin
        tmpi-=1
    end
end

# Fonction qui permet l'evaluation des Hprio
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return ::Int : la difference de Hprio violer
function eval_Hprio_reflection(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation1::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    tab_violation = deepcopy(tab_violation1)
    tmp_viol=0
    for i in 1:Hprio
        tab_deb=[0 for i in 1:ratio_option[i][2]-1]
        tab_fin=[0 for i in 1:ratio_option[i][2]-1]
        for j in 0:min(l-k-1,ratio_option[i][2]-2,sz-k)

            if sequence_courante[min(sz,k+j)][i+2]!=sequence_courante[max(1,l-j)][i+2]
                if sequence_courante[k+j][i+2]==1
                    tab_fin[j+1]+=1
                    tab_deb[j+1]-=1
                elseif sequence_courante[max(1,l-j)][i+2]==1
                    tab_fin[j+1]-=1
                    tab_deb[j+1]+=1
                end
            end
            if j>0
                tab_fin[j+1]+=tab_fin[j]
                tab_deb[j+1]+=tab_deb[j]
            end
            tab_violation[i][k+j] += tab_deb[j+1]
            if (l-j+ratio_option[i][2]-1<=sz)
                tab_violation[i][l-j+ratio_option[i][2]-1] += tab_fin[j+1]
                tmp_viol+=max(0,tab_violation[i][l-j+ratio_option[i][2]-1])
            end
            tmp_viol+=max(0,tab_violation[i][k+j])
        end
    end

    return tmp_viol
end

# Fonction qui evalue la difference de EP si on effectu la reflection k,l
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le nombre de Hprio
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de ENP de difference
function eval_Lprio_reflection(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation1::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    tab_violation = deepcopy(tab_violation1)
    tmp_viol=0
    for i in Hprio+1:size(ratio_option)[1]
        tab_deb=[0 for i in 1:ratio_option[i][2]-1]
        tab_fin=[0 for i in 1:ratio_option[i][2]-1]
        for j in 0:min(l-k-1,ratio_option[i][2]-2,sz-k)

            if sequence_courante[min(sz,k+j)][i+2]!=sequence_courante[max(1,l-j)][i+2]
                if sequence_courante[k+j][i+2]==1
                    tab_fin[j+1]+=1
                    tab_deb[j+1]-=1
                elseif sequence_courante[max(1,l-j)][i+2]==1
                    tab_fin[j+1]-=1
                    tab_deb[j+1]+=1
                end
            end
            if j>0
                tab_fin[j+1]+=tab_fin[j]
                tab_deb[j+1]+=tab_deb[j]
            end
            tab_violation[i][k+j] += tab_deb[j+1]
            if (l-j+ratio_option[i][2]-1<=sz)
                tab_violation[i][l-j+ratio_option[i][2]-1] += tab_fin[j+1]
                tmp_viol+=max(0,tab_violation[i][l-j+ratio_option[i][2]-1])
            end
            tmp_viol+=max(0,tab_violation[i][k+j])
        end
    end
    return tmp_viol
end




# =====================================================================
# ====================          swap                ===================
# =====================================================================

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
function swap!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    # Realisation du benefice ou non du mvt
    szcar =size(sequence_courante[1])[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0
    cond = eval_pbl_swap(sequence_courante, col_avant, pbl, k, l)
    if !cond
        return false
    end
    for o in obj
        if o==1 #&& (rand_mov!=:border_block_two! ||rand_mov!=:same_color!||rand_mov!=:violation_same_color!)
            tmp_color = eval_couleur_swap(sequence_courante, col_avant, pbl, k, l)
            cond = tmp_color<=0
            if tmp_color<0
                break
            end
        elseif o==2
            tmp_Hprio = eval_Hprio_swap(sequence_courante, ratio_option, tab_violation, Hprio, k, l)
            cond = tmp_Hprio <=0
            if tmp_Hprio<0
                break
            end
        elseif o==3
            tmp_Lprio = eval_Lprio_swap(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
            if tmp_Lprio<0
                break
            end
        end
        # Si ça n'ameliore pas alors on fait rien
        if !cond
            return false
        end
    end
    # Sinon on realise le mouvement de swap :

    #aa , b =evaluation_init(sequence_courante,ratio_option,Hprio)
    tmp=copy(sequence_courante[k])
    sequence_courante[k]=sequence_courante[l]
    sequence_courante[l]=tmp
    # Mise à jour du tableau de violation et pbl :
    update_tab_violation_and_pbl_swap!(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)

    return true

    nothing # Pas de return pour eviter les copies de memoire.
end

# Fontion qui evalue la difference de RAF si on effectu le swap k,l
# @param sequence_courante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Bool : si c'est autorisé comme changement
function eval_couleur_swap(sequence_courante::Array{Array{Int,1},1}, col_avant::Tuple{Int32,Int32}, pbl::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return tmp_color
    end
    if l-k>1

        if sequence_courante[k][2]==sequence_courante[l-1][2]
            tmp_color-=1
        elseif sequence_courante[l][2]==sequence_courante[l-1][2]
            tmp_color+=1
        end

        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                tmp_color-=1
            elseif sequence_courante[l][2]==sequence_courante[l+1][2]
                tmp_color+=1
            end
        end

        if sequence_courante[l][2]==sequence_courante[k+1][2]
            tmp_color-=1
        elseif sequence_courante[k][2]==sequence_courante[k+1][2]
            tmp_color+=1
        end

        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                tmp_color-=1
            elseif sequence_courante[k][2]==sequence_courante[k-1][2]
                tmp_color+=1
            end
        else
            if sequence_courante[l][2]==col_avant[2]
                tmp_color-=1
            end
            if sequence_courante[k][2]==col_avant[2]
                tmp_color+=1
            end
        end


    else
        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                tmp_color-=1
            elseif sequence_courante[l][2]==sequence_courante[l+1][2]
                tmp_color+=1
            end
        end

        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                tmp_color-=1
            elseif sequence_courante[k][2]==sequence_courante[k-1][2]
                tmp_color+=1
            end
        end

    end

    return tmp_color
end

# Fonction qui verifie que la nouvelle sequeence est admissible
# @param sequence_courante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
function eval_pbl_swap(sequence_courante::Array{Array{Int,1},1}, col_avant::Tuple{Int32,Int32},pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return true
    end

    if l-k>1
        if sequence_courante[k][2]==sequence_courante[l-1][2]
            if sequence_courante[l-1][szcar-1]-sequence_courante[l-1][szcar-2]+1+1>pbl
                return false
            end
        end
        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                if sequence_courante[l+1][szcar-1]-sequence_courante[l+1][szcar-2]+1+1>pbl
                    return false
                end
            end
            if sequence_courante[k][2]==sequence_courante[l+1][2]&& sequence_courante[k][2]==sequence_courante[l-1][2]
                if sequence_courante[l+1][szcar-1]-sequence_courante[l-1][szcar-2]+1>pbl
                    return false
                end
            end
        end
        if sequence_courante[l][2]==sequence_courante[k+1][2]
            if sequence_courante[k+1][szcar-1]-sequence_courante[k+1][szcar-2]+1+1>pbl
                return false
            end
        end
        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                if sequence_courante[k-1][szcar-1]-sequence_courante[k-1][szcar-2]+1+1>pbl
                    return false
                end
            end
            if sequence_courante[l][2]==sequence_courante[k+1][2]&& sequence_courante[l][2]==sequence_courante[k-1][2]
                if sequence_courante[k+1][szcar-1]-sequence_courante[k-1][szcar-2]+1+1>pbl
                    return false
                end
            end
        else
            if sequence_courante[l][2]==col_avant[2]
                if col_avant[1]+1+1>pbl
                    return false
                end
            end
            if sequence_courante[l][2]==sequence_courante[k+1][2]&& sequence_courante[l][2]==col_avant[2]
                if col_avant[1]+sequence_courante[k+1][szcar-1]-k+1+1>pbl
                    return false
                end
            end
        end
    else
        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                if sequence_courante[l+1][szcar-1]-l+1+1+1>pbl
                    return false
                end
            end
        end

        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                if k-1-sequence_courante[k-1][szcar-2]+1+1>pbl
                    return false
                end
            end

        end

    end


    return true
end

# Fonction qui evalue la difference de EP si on effectu le swap k,l
# @param sequence_courante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return Int : le nombre de EP de difference
function eval_Hprio_swap(sequence_courante::Array{Array{Int,1},1}, ratio_option::Array{Array{Int,1},1}, tab_violation::Array{Array{Int,1},1}, Hprio::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:Hprio
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(l-1,k+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>0)
                        tmp_viol-=1
                    end
                end
                for j in max(l,k+ratio_option[i][2]):min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in max(l,k+ratio_option[i][2]):min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(l-1,k+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    ###println(tmp_viol)
    return tmp_viol
end

# Fonction qui reevalue les color et le tab_violation de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : les tableau sont maj
# @modify sequence_courante : modifie les fenetre dans la sequence
function update_tab_violation_and_pbl_swap!(sequence_courante::Array{Array{Int,1},1}, ratio_option::Array{Array{Int,1},1}, tab_violation,Hprio::Int, pbl::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]


    ## update des color k
    if sequence_courante[k][2]!=sequence_courante[l][2]

        if k> 1 && sequence_courante[k][2]==sequence_courante[k-1][2]
            if sequence_courante[k][2]==sequence_courante[k+1][2]
                for i in sequence_courante[k-1][szcar-2]:sequence_courante[k+1][szcar-1]
                    sequence_courante[i][szcar-2] = sequence_courante[k-1][szcar-2]
                    sequence_courante[i][szcar-1] = sequence_courante[k+1][szcar-1]
                end
            else
                for i in sequence_courante[k-1][szcar-2]:k
                    sequence_courante[i][szcar-2] = sequence_courante[k-1][szcar-2]
                    sequence_courante[i][szcar-1] = k
                end
                if sequence_courante[l][2]==sequence_courante[k+1][2]
                    for i in k+1:sequence_courante[k+1][szcar-1]
                        sequence_courante[i][szcar-2] = k+1
                        sequence_courante[i][szcar-1] = sequence_courante[k+1][szcar-1]
                    end
                end
            end
        else
            if sequence_courante[k][2]==sequence_courante[k+1][2]
                for i in k:sequence_courante[k+1][szcar-1]
                    sequence_courante[i][szcar-2] = k
                    sequence_courante[i][szcar-1] = sequence_courante[k+1][szcar-1]
                end
                if k>1 && sequence_courante[l][2]==sequence_courante[k-1][2]
                    for i in sequence_courante[k-1][szcar-2]:k-1
                        sequence_courante[i][szcar-2] = sequence_courante[k-1][szcar-2]
                        sequence_courante[i][szcar-1] = k-1
                    end
                end
            else
                sequence_courante[k][szcar-2] = k
                sequence_courante[k][szcar-1] = k
                if k>1 && sequence_courante[l][2]==sequence_courante[k-1][2]
                    for i in sequence_courante[k-1][szcar-2]:k-1
                        sequence_courante[i][szcar-2] = sequence_courante[k-1][szcar-2]
                        sequence_courante[i][szcar-1] = k-1
                    end
                end
                if sequence_courante[l][2]==sequence_courante[k+1][2]
                    for i in k+1:sequence_courante[k+1][szcar-1]
                        sequence_courante[i][szcar-2] = k+1
                        sequence_courante[i][szcar-1] = sequence_courante[k+1][szcar-1]
                    end
                end
            end
        end

        if sequence_courante[l][2]==sequence_courante[l-1][2]
            if l<sz && sequence_courante[l][2]==sequence_courante[l+1][2]
                for i in sequence_courante[l-1][szcar-2]:sequence_courante[l+1][szcar-1]
                    sequence_courante[i][szcar-2] = sequence_courante[l-1][szcar-2]
                    sequence_courante[i][szcar-1] = sequence_courante[l+1][szcar-1]
                end
            else
                for i in sequence_courante[l-1][szcar-2]:l
                    sequence_courante[i][szcar-2] = sequence_courante[l-1][szcar-2]
                    sequence_courante[i][szcar-1] = l
                end
                if  l<sz && sequence_courante[k][2]==sequence_courante[l+1][2]
                    for i in l+1:sequence_courante[l+1][szcar-1]
                        sequence_courante[i][szcar-2] = l+1
                        sequence_courante[i][szcar-1] = sequence_courante[l+1][szcar-1]
                    end
                end
            end
        else
            if  l<sz && sequence_courante[l][2]==sequence_courante[l+1][2]
                for i in l:sequence_courante[l+1][szcar-1]
                    sequence_courante[i][szcar-2] = l
                    sequence_courante[i][szcar-1] = sequence_courante[l+1][szcar-1]
                end
                if sequence_courante[k][2]==sequence_courante[l-1][2]
                    for i in sequence_courante[l-1][szcar-2]:l-1
                        sequence_courante[i][szcar-2] = sequence_courante[l-1][szcar-2]
                        sequence_courante[i][szcar-1] = l-1
                    end
                end
            else
                sequence_courante[l][szcar-2] = l
                sequence_courante[l][szcar-1] = l
                if sequence_courante[k][2]==sequence_courante[l-1][2]
                    for i in sequence_courante[l-1][szcar-2]:l-1
                        sequence_courante[i][szcar-2] = sequence_courante[l-1][szcar-2]
                        sequence_courante[i][szcar-1] = l-1
                    end
                end
                if l<sz && sequence_courante[k][2]==sequence_courante[l+1][2]
                    for i in l+1:sequence_courante[l+1][szcar-1]
                        sequence_courante[i][szcar-2] = l+1
                        sequence_courante[i][szcar-1] = sequence_courante[l+1][szcar-1]
                    end
                end
            end
        end

    else
        tmpdeb =sequence_courante[l][szcar-2]
        tmpfin =sequence_courante[l][szcar-1]
        sequence_courante[l][szcar-2]=sequence_courante[k][szcar-2]
        sequence_courante[l][szcar-1]=sequence_courante[k][szcar-1]
        sequence_courante[k][szcar-2]=tmpdeb
        sequence_courante[k][szcar-1]=tmpfin
    end





    ## update du tab_violation
    for i in 1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(l-1,k+ratio_option[i][2]-1)
                    tab_violation[i][j]+=1
                end
                for j in max(l,k+ratio_option[i][2]):min(sz,l+ratio_option[i][2]-1)
                    tab_violation[i][j]-=1
                end
            elseif sequence_courante[l][i+2]==1
                for j in max(l,k+ratio_option[i][2]):min(sz,l+ratio_option[i][2]-1)
                    tab_violation[i][j]+=1
                end
                for j in k:min(l-1,k+ratio_option[i][2]-1)
                    tab_violation[i][j]-=1
                end
            end
        end
    end
end

# Fonction qui evalue la difference de EP si on effectu le swap k,l
# @param sequence_courante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de ENP de difference
function eval_Lprio_swap(sequence_courante::Array{Array{Int,1},1}, ratio_option::Array{Array{Int,1},1}, tab_violation::Array{Array{Int,1},1}, Hprio::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in Hprio+1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(l-1,k+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>0)
                        tmp_viol-=1
                    end
                end
                for j in max(l,k+ratio_option[i][2]):min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in max(l,k+ratio_option[i][2]):min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(l-1,k+ratio_option[i][2]-1)
                    if(tab_violation[i][j]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end

    return tmp_viol
end



# =====================================================================
# =============                Random shuffle         =================
# =====================================================================



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
function shuffle!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},col_avant::Tuple{Int32,Int32}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    sz = size(sequence_courante)[1]
    szcar = size(sequence_courante[1])[1]
    l = rand(5:15,1)[1]


    k = rand(20:sz-l,1)[1]

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
    cond = eval_pbl_shuffle(sequence_courante,seq,pbl,k,l)
    if !cond
        return false
    end
    for o in obj

        if o==1
            tmp_color = eval_couleur_shuffle(sequence_courante,seq,pbl,k,l)
            cond_no = tmp_color<=0
            cond_ui =tmp_color<0
        elseif o==2

            tmp_Hprio = eval_Hprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)
            cond_no = tmp_Hprio<=0
            cond_ui =tmp_Hprio<0

        elseif o==3

            tmp_Lprio = eval_Lprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)
            cond_no = tmp_Lprio<=0
            cond_ui =tmp_Lprio<0
        end
        if !cond_no
            return false
        end
        if(cond_ui)
            break
        end

    end

    #aa , b =evaluation_init(sequence_courante,ratio_option,Hprio)

    update_tab_violation_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l+k-1),sequence_courante[seq])
    update_col_and_pbl_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
#=
        col = sequence_courante[1][2]
        deb = sequence_courante[1][szcar-2]
        fin = sequence_courante[1][szcar-1]
        for i in 1:1:size(sequence_courante)[1]

            if col !=  sequence_courante[i][2]
                col = sequence_courante[i][2]
                if fin+1 != sequence_courante[i][szcar-2]
                    for car in sequence_courante
                        println(car)
                    end
                    println("k : ",k, " l : ", l)
                    println(sequence_courante[k])
                    println(sequence_courante[l])
                    println(i)
                    return FAUX
                end
                deb = sequence_courante[i][szcar-2]
                fin = sequence_courante[i][szcar-1]
            else
                if fin != sequence_courante[i][szcar-1] || deb != sequence_courante[i][szcar-2]

                    for car in sequence_courante
                        println(car)
                    end
                    println("k : ",k, " l : ", l)
                    println(sequence_courante[k])
                    println(sequence_courante[l])
                    return FAUXXXXX
                end
            end

        end
    #a , b =evaluation_init(sequence_courante,ratio_option,Hprio)
=#
    #=
    if (a[1]==aa[1]&&a[2]==aa[2]&& a[3]>aa[3])
        ##println(tmp_Hprio)
        ##println(aa)
        ##println(a)
        return shuffle
    end=#

    return true
end

# Sincerement j'ai la flemme de commenter ça # tqt je comprend xDD d
function update_col_and_pbl_shuffle(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},sequence::Array{Int,1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]

    ## update des color
    tmpkdeb=k
    while tmpkdeb>=1 &&(sequence_courante[k][2]==sequence_courante[tmpkdeb][2])
        tmpkdeb-=1
    end
    tmpkdeb+=1
    debk = tmpkdeb


    tmplfin=k+l-1
    while tmplfin<=sz && sequence_courante[k+l-1][2]==sequence_courante[tmplfin][2]
        tmplfin+=1

    end
    tmplfin-=1
    finl = tmplfin

    deb = debk
    col = sequence_courante[deb][2]
    for i in debk:finl
        if sequence_courante[i][2]!= col
            col=sequence_courante[i][2]
            deb = i
        end
        sequence_courante[i][szcar-2]=deb
    end

    fin = finl
    tmpi = fin
    col=sequence_courante[fin][2]
    for i in debk:finl

        if sequence_courante[tmpi][2]!= col
            col=sequence_courante[tmpi][2]
            fin = tmpi
        end
        sequence_courante[tmpi][szcar-1]=fin
        tmpi-=1
    end

    if k>1 && sequence_courante[k][2]!=sequence_courante[k-1][2] && k-1!=sequence_courante[k-1][szcar-1]
        for i in sequence_courante[k-1][szcar-2]:k-1
            sequence_courante[i][szcar-2]=sequence_courante[k-1][szcar-2]
            sequence_courante[i][szcar-1]=k-1
        end
    end
    if k+l-1<sz && sequence_courante[k+l-1][2]!=sequence_courante[k+l][2] && sequence_courante[k+l][szcar-2]!=k+l
        for i in k+l:sequence_courante[k+l][szcar-1]
            sequence_courante[i][szcar-2]=k+l
            sequence_courante[i][szcar-1]=sequence_courante[k+l][szcar-1]
        end
    end

end

# Fonction qui reevalue les color et le tab_violation de la new sol
# @param sequence_courante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param sequence : ???? quesaco
# @param Hprio : le tableau des H
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : les tableau sont maj
function update_tab_violation_shuffle(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},sequence::Array{Int,1},Hprio::Int,pbl::Int,k::Int,l::Int)
    ## update du tab_violation
    sz = size(sequence_courante)[1]
    tmp_viol=0
    l = size(sequence)[1]
    for i in 1:size(ratio_option)[1]
        kk = k
        for l in sequence
            if sequence_courante[kk][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[kk][i+2]==1
                    for j in max(kk,ratio_option[i][2]-1):min(sz,kk+ratio_option[i][2]-1)
                        tab_violation[i][j]-=1
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in max(kk,ratio_option[i][2]-1):min(sz,kk+ratio_option[i][2]-1)
                        tab_violation[i][j]+=1
                    end
                end
            end
            kk+=1
        end
    end
end

# Fonction qui evalue la difference des hprio si on effectu le shuffle k,l
# @param sequence_courante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de EP de difference
function eval_Hprio_shuffle(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation1::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int,sequence)
    sz = size(sequence_courante)[1]
    kk=k
    tmp_viol=0
    tab_violation = deepcopy(tab_violation1)
    l = size(sequence)[1]
    for i in 1:Hprio
        k = kk
        for l in sequence
            if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[k][i+2]==1
                    for j in max(k,ratio_option[i][2]-1):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[i][j]-=1
                        if(tab_violation[i][j]>=0)
                            tmp_viol-=1
                        end
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in max(k,ratio_option[i][2]-1):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[i][j]+=1
                        if(tab_violation[i][j]>0)
                            tmp_viol+=1
                        end
                    end
                end
            end
            k+=1
        end
    end

    return tmp_viol
end

# Fonction qui evalue la difference des lprio si on effectu le shuffle k,l
# @param sequence_courante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de EP de difference
function eval_Lprio_shuffle(sequence_courante::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1},1},tab_violation1::Array{Array{Int,1},1},Hprio::Int,k::Int,l::Int,sequence)
    sz = size(sequence_courante)[1]
    kk=k
    tmp_viol=0
    tab_violation = deepcopy(tab_violation1)
    l = size(sequence)[1]
    for i in Hprio+1:size(ratio_option)[1]
        k = kk
        for l in sequence
            if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[k][i+2]==1
                    for j in max(k,ratio_option[i][2]):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[i][j]-=1
                        if(tab_violation[i][j]>=0)
                            tmp_viol-=1
                        end
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in max(k,ratio_option[i][2]):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[i][j]+=1
                        if(tab_violation[i][j]>0)
                            tmp_viol+=1
                        end
                    end
                end
            end
            k+=1
        end
    end
    k=kk

    return tmp_viol
end

# Fonction qui evalue la difference des lprio si on effectu le shuffle k,l
# @param sequence_courante : la sequence ou instance courante
# @param sequence : ???? quesaco
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de EP de difference
function eval_couleur_shuffle(sequence_courante::Array{Array{Int,1},1},sequence::Array{Int,1},pbl::Int,k::Int,l::Int)

    szcar = size(sequence_courante[1])[1]
    sz = size(sequence_courante)[1]

    deb = 1
    deb = max(1,k-1)
    fin = sz
    fin = min(k+l-1,sz)
    col = sequence_courante[deb][2]
    nbcol=0
    tmpi = sequence_courante[deb][szcar-1]

    while tmpi<=fin && tmpi<sz
        tmpi = sequence_courante[tmpi+1][szcar-1]
        nbcol+=1
    end

    col = sequence_courante[max(1,k-1)][2]

    tmpnbcol = 0
    for i in k:k+l-1
        if sequence_courante[sequence[i-k+1]][2]!= col
            tmpnbcol+=1
            col=sequence_courante[sequence[i-k+1]][2]
        end
        if(tmpnbcol>nbcol)
            return 1
        end
    end
    if sequence_courante[k+l][2]!= col
        tmpnbcol+=1
    end

    if (tmpnbcol>nbcol)
        return 1
    end

    return tmpnbcol-nbcol
end

# Fonction qui evalue la difference des lprio si on effectu le shuffle k,l
# @param sequence_courante : la sequence ou instance courante
# @param sequence : ???? quesaco
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de EP de difference
function eval_pbl_shuffle(sequence_courante::Array{Array{Int,1},1},sequence::Array{Int,1},pbl::Int,k::Int,l::Int)

    szcar = size(sequence_courante[1])[1]
    sz = size(sequence_courante)[1]


    deb = max(1,k-1)
    fin = min(k+l-1,sz)
    col = sequence_courante[deb][2]

    tmp_pbl=max(1,k-1)- sequence_courante[max(1,k-1)][szcar-2]+1

    for i in k:k+l-1
        if sequence_courante[sequence[i-k+1]][2]!= col
            col=sequence_courante[sequence[i-k+1]][2]
            tmp_pbl=1
        end
        tmp_pbl+=1
        if tmp_pbl>pbl
            return false
        end
    end
    if sequence_courante[k+l][2]== col
        tmp_pbl+=(sequence_courante[k+l][szcar-1]-k-l)+1
    end

    if tmp_pbl>pbl
        return false

    end

    return true
end
