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
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function swap!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
    tmp=sequence_courrante[k]
    sequence_courrante[k]=sequence_courrante[l]
    sequence_courrante[l]=tmp
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de swap
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_swap!(sequence_courrante::Array{Array{Int64,1},1}, k::Int64, l::Int64, score_courrant::Array{Int64,1},prio::Array{Array{Int64,1}},Hprio::Int64,obj::Array{Int64,1},pbl::Int64)
    score_init=[0,0,0]
    tmp_violation=Int64(0)
    #Evaluation initiale
    for i in 1:length(prio)
        tmp_val_courrante=sequence_courrante[max(k-prio[i][2],1)][i+2]
        for j in max(k+1-prio[i][2],2):k
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
    for j in  max(k+1-pbl,2):k
        if sequence_courrante[j][2] != tmp_val_courrante
            tmp_violation+=1
        end
    end
    score_init[1]+=tmp_violation
    #On effectu le changement
    swap!(sequence_courrante,k,l)

    #Deuxième eval
    score_final=[0,0,0]
    tmp_violation=0
    for i in 1:length(prio)
        tmp_val_courrante=sequence_courrante[max(k-prio[i][2],1)][i+2]
        for j in  max(k+1-prio[i][2],2):k
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
    for j in max(k+1-pbl,2):k
        if sequence_courrante[j][2] != tmp_val_courrante
            tmp_violation+=1
        end
    end
    score_final[1]+=tmp_violation
    #On accepte ou non le swap
    if score_final[obj[1]]>1.05*score_init[obj[1]]
        swap!(sequence_courrante,k,l)
        return false
    else
        return true
    end
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
