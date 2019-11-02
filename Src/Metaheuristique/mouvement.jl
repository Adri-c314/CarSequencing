# Fonction qui permet de verifier qu'un mouvement est bien améliorant
# @param LSfoo!::Function : LSfoo! doit etre une des fonctions de recherche locale (swap!, fw_insertion!, bw_insertion!, reflection!, permutation!). Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function global_test_mouvement!(LSfoo!::Function, sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
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
function global_mouvement!(LSfoo!::Function, sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32)
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
function fw_insertion!(sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32)
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
function test_fw_insertion!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
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
function permutation!(sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32)
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
function test_permutation!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
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
function reflection!(sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32)
   #TODO : Realise la reflection tranquille pepere sans te soucier de rien
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de reflection
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_reflection!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
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
function swap!(sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32)
   #TODO : Realise le swap tranquille pepere sans te soucier de rien
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de swap
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_swap!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
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
function bw_insertion!(sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32)
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
function test_bw_insertion!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
end
