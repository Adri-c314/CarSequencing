# Fichier tous les algorithms gloutons et leurs foncions associées
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 1



# Fonction qui permet de verifier qu'un mouvement est bien améliorant
# @param LSfoo!::Function : LSfoo! doit etre une des fonctions de recherche locale (swap!, fw_insertion!, bw_insertion!, reflection!, permutation!). Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function global_test_mouvement!(LSfoo!::Function, sequence_courrante::Array{Array{Int64,1},1}, score_courrant::Array{Int64,1}, k::UInt64, l::UInt64)
   if LSfoo! == swap!
       return test_swap!(sequence_courrante, score_courrant, k, l)
   elseif LSfoo! == fw_insertion!
       return test_fw_insertion!(sequence_courrante, score_courrant, k, l)
   elseif LSfoo! == bw_insertion!
       return test_bw_insertion!(sequence_courrante, score_courrant, k, l)
   elseif LSfoo! == reflection!
       return test_reflection!(sequence_courrante, score_courrant, k, l)
   elseif LSfoo! == permutation!
       return test_permutation!(sequence_courrante, score_courrant, k, l)
   end
   return false
end

#  Pas utile : LSfoo! est un pointeur sur une fonction, il suffit de faire LSfoo!(sequence_courrante, k, l), pas besoin de switch. Mais on peut laisser pour harmoniser avec la fonction global_test_mouvement!.
# Fonction qui fait appelle à la bonne fonction de mouvement
# @param LSfoo!::Function : LSfoo! doit etre une des fonctions de recherche locale (swap!, fw_insertion!, bw_insertion!, reflection!, permutation!). Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????

function global_mouvement!(LSfoo!::Function, sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   #=
   if LSfoo! == :swap!
       swap!(sequence_courrante, k, l)
   elseif LSfoo! == :fw_insertion!
       fw_insertion!(sequence_courrante, k, l)
   elseif LSfoo! == :bw_insertion!
       bw_insertion!(sequence_courrante, k, l)
   elseif LSfoo! == :reflection!
       reflection!(sequence_courrante, k, l)
   elseif LSfoo! == :permutation!
       permutation!(sequence_courrante, k, l)
   end
   =#
   LSfoo!(sequence_courrante, k, l)
   nothing
end






# =====================================================================
# =========              forward insertion              ===============
# =====================================================================

# Fonction principale du mouvement de forward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
function fw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   #TODO : Realise la fw_insertion tranquille pepere sans te soucier de rien
   nothing
end



# Fonction d'evaluation du mouvement de forward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_fw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, score_courrant::Array{Int64,1}, k::UInt64, l::UInt64)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
end





# =====================================================================
# ====================            permuation         ==================
# =====================================================================

# Fonction principale du mouvement de permuation
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
function permutation!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   #TODO : Realise la permutation tranquille pepere sans te soucier de rien
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de permuation
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_permutation!(sequence_courrante::Array{Array{Int64,1},1}, score_courrant::Array{Int64,1}, k::UInt64, l::UInt64)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
end





# =====================================================================
# ====================           reflection         ===================
# =====================================================================

# Fonction principale du mouvement de reflection
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function reflection!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
    for i in 1:floor(l-k/2)
        tmp=sequence_courrante[k+i]
        sequence_courrante[k+i]=sequence_courrante[l-i]
        sequence_courrante[l-i]=tmp
    end
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de reflection
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_reflection!(sequence_courrante::Array{Array{Int64,1},1}, score_courrant::Array{Int64,1}, k::UInt64, l::UInt64,prio::Array{Array{Int64,1}},Hprio::Int64,obj::Array{Int64,1},pbl::Int64)
    core_init=[0,0,0]
    tmp_violation=Int64(0)
    #Evaluation initiale
    for i in 1:length(prio)
        tmp_val_courrante=sequence_courrante[max(k-prio[i][2],1)][i+2]
        for j in max(k+1-prio[i][2],2):l
            if sequence_courrante[j][i+2] != tmp_val_courrante
                tmp_violation+=1
            end
        end
        if i>Hprio
            score_init[3]+=tmp_violation
        else
            score_init[2]+=tmp_violation
        end
        tmp_violation=0
    end

    tmp_val_courrante=sequence_courrante[max(k-pbl,1)][2]
    for j in  max(k+1-pbl,2):l
        if sequence_courrante[j][2] != tmp_val_courrante
            tmp_violation+=1
        end
    end
    score_init[1]+=tmp_violation
   return true

    #On applique le mouvement
    reflection!(sequence_courrante,k,l)

    #Eval du mouvement
    score_final=[0,0,0]
    tmp_violation=0
    for i in 1:length(prio)
        tmp_val_courrante=sequence_courrante[max(k-prio[i][2],1)][i+2]
        for j in  max(k+1-prio[i][2],2):l
            if sequence_courrante[j][i+2] != tmp_val_courrante
                tmp_violation+=1
            end
        end
        if i>Hprio
            score_final[3]+=tmp_violation
        else
            score_final[2]+=tmp_violation
        end
        tmp_violation=0
    end

    tmp_val_courrante=sequence_courrante[max(k-pbl,1)][2]
    for j in max(k+1-pbl,2):l
        if sequence_courrante[j][2] != tmp_val_courrante
            tmp_violation+=1
        end
    end
    score_final[1]+=tmp_violation

    #On accepte ou non la reflection
    if score_final[obj[1]]>1.05*score_init[obj[1]]
        reflection!(sequence_courrante,k,l)
        return false
    else
        return true
    end
end



# =====================================================================
# ====================          swap                ===================
# =====================================================================

# Fonction principale du mouvement de swap
# @param sequence_courrante : la sequence ou instance courante
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
function swap!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64, ratio_option::Array{Array{Int64,1}}, tab_violation::Array{Array{Int64,1}}, Hprio::Int64, obj::Array{Int64,1}, pbl::Int64, rand_mov::Symbol)
    # Realisation du benefice ou non du mvt
    cond = true
    tmp_color=0
    for o in obj
        if o==1 && (rand_mov!=:border_block_two! ||rand_mov!=:same_color!||rand_mov!=:violation_same_color!)
            tmp_color = eval_couleur_swap(sequence_courante, pbl, k, l)
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
            return
        end
    end

    # Sinon on realise le mouvement de swap :
    tmp=sequence_courante[k]
    sequence_courante[k]=sequence_courante[l]
    sequence_courante[l]=tmp

    # Mise à jour du tableau de violation et pbl :
    update_tab_violation_and_pbl_swap!(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)

    nothing # Pas de return pour eviter les copies de memoire.
end



# Fontion qui evalue la difference de RAF si on effectu le swap k,l
# @param sequence_courrante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Bool : si c'est autorisé comme changement
function eval_couleur_swap(sequence_courante::Array{Array{Int64,1},1}, pbl::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return tmp_color
    end

    if sequence_courante[k][2]==sequence_courante[l-1][2]
        if sequence_courante[l-1][szcar-1]-sequence_courante[l-1][szcar-2]==pbl
            return 1
        end
        tmp_color-=1
    end

    if l<sz
        if sequence_courante[k][2]==sequence_courante[l+1][2]
            if sequence_courante[l+1][szcar-1]-sequence_courante[l+1][szcar-2]==pbl
                return 1
            end
            tmp_color-=1
        end

        if sequence_courante[k][2]==sequence_courante[l+1][2]&& sequence_courante[k][2]==sequence_courante[l-1][2]
            if sequence_courante[l+1][szcar-1]-sequence_courante[l-1][szcar-2]>pbl
                return 1
            end
        end
    end

    if sequence_courante[l][2]==sequence_courante[k+1][2]
        if sequence_courante[k+1][szcar-1]-sequence_courante[k+1][szcar-2]==pbl
            return 1
        end
        tmp_color-=1
    end

    if k>1
        if sequence_courante[l][2]==sequence_courante[k-1][2]
            if sequence_courante[k-1][szcar-1]-sequence_courante[k-1][szcar-2]==pbl
                return 1
            end
            tmp_color-=1
        end

        if sequence_courante[l][2]==sequence_courante[k+1][2]&& sequence_courante[l][2]==sequence_courante[k-1][2]
            if sequence_courante[k+1][szcar-1]-sequence_courante[k-1][szcar-2]>pbl
                return 1
            end
        end
    end

    if sequence_courante[l][2]==sequence_courante[l-1][2]
        tmp_color+=1
    end
    if l<sz && sequence_courante[l][2]==sequence_courante[l+1][2]
        tmp_color+=1
    end
    if sequence_courante[k][2]==sequence_courante[k+1][2]
        tmp_color+=1
    end
    if k>1 && sequence_courante[k][2]==sequence_courante[k-1][2]
        tmp_color+=1
    end

    return tmp_color
end



# Fonction qui evalue la difference de EP si on effectu le swap k,l
# @param sequence_courrante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return Int : le nombre de EP de difference
function eval_Hprio_swap(sequence_courante::Array{Array{Int64,1},1}, ratio_option::Array{Array{Int64,1},1}, tab_violation::Array{Array{Int64,1},1}, Hprio::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:Hprio
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    #println(tmp_viol)
    return tmp_viol
end



# Fonction qui reevalue les color et le tab_violation de la new sol
# @param sequence_courrante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : les tableau sont maj
# @modify sequence_courrante : modifie les fenetre dans la sequence
function update_tab_violation_and_pbl_swap!(sequence_courante::Array{Array{Int64,1},1}, ratio_option::Array{Array{Int64,1},1}, tab_violation,Hprio::Int64, pbl::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]

    ## update des color k
    tmpkdeb=k
    tmpkfin=k
    while tmpkdeb>1 &&(sequence_courante[k][2]==sequence_courante[tmpkdeb][2])
        tmpkdeb-=1
    end
    tmpkdeb+=1
    debk = tmpkdeb


    while tmpkfin<sz &&(sequence_courante[k][2]==sequence_courante[tmpkfin][2])
        tmpkfin+=1
    end
    tmpkfin-=1
    fink = tmpkfin
    while tmpkfin>debk
        sequence_courante[tmpkfin][szcar-2]= tmpkdeb
        sequence_courante[tmpkfin][szcar-1]= fink
        tmpkfin-=1
    end


    ## update des color l
    tmpldeb=l
    tmplfin=l

    while tmpldeb>1 &&(sequence_courante[l][2]==sequence_courante[tmpldeb][2])
        tmpldeb-=1
    end
    tmpldeb+=1
    debl = tmpldeb

    while tmplfin<sz &&(sequence_courante[l][2]==sequence_courante[tmplfin][2])
        tmplfin+=1
    end
    tmplfin-=1
    finl = tmplfin
    while tmplfin>debl
        sequence_courante[tmplfin][szcar-2]= tmpldeb
        sequence_courante[tmplfin][szcar-1]= finl
        tmplfin-=1
    end

    ## update du tab_violation
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    tab_violation[j][i]+=1
                end
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    tab_violation[j][i]-=1
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    tab_violation[j][i]+=1
                end
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    tab_violation[j][i]-=1
                end
            end
        end
    end
end



# Fonction qui evalue la difference de EP si on effectu le swap k,l
# @param sequence_courrante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de ENP de difference
function eval_Lprio_swap(sequence_courante::Array{Array{Int64,1},1}, ratio_option::Array{Array{Int64,1},1}, tab_violation::Array{Array{Int64,1},1}, Hprio::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in Hprio+1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    return tmp_viol
end





# =====================================================================
# =============              backward insertion       =================
# =====================================================================

# Fonction principale du mouvement de backward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function bw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   #TODO : Realise la bw_insertion tranquille pepere sans te soucier de rien
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de backward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_bw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, score_courrant::Array{Int64,1}, k::UInt64, l::UInt64)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
end
