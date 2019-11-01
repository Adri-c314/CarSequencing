# Fichier tous les algorithms gloutons et leurs foncions associées
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 1



# =====================================================================
# =========     recherche local forward insertion       ===============
# =====================================================================

# Fonction principale de la recherche local forward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : les valeur de score courant sur tous les objs
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function fw_insertion!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing
end



#
function rechercheLocalFw()

end





# =====================================================================
# ==================== recherche locale permuation   ==================
# =====================================================================

# Fonction principale de la recherche locale permuation
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : les valeur de score courant sur tous les objs
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function permutation!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end





# =====================================================================
# ==================== recherche locale reflection   ==================
# =====================================================================

# Fonction principale de la recherche locale reflection
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : les valeur de score courant sur tous les objs
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function reflection!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end





# =====================================================================
# ==================== recherche locale avec swap   ===================
# =====================================================================

# Fonction principale de la recherche locale avec swap
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : les valeur de score courant sur tous les objs
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function swap!(sequence_courrante::Array{Array{Int32,1},1}, k::UInt32, l::UInt32, score_courrant::Array{Int32,1})
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end




# =====================================================================
# ============= recherche locale backward insertion   =================
# =====================================================================

# Fonction principale de la recherche locale backward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : les valeur de score courant sur tous les objs
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function bw_insertion!(sequence_courrante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end
