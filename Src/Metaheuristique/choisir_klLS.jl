# Squelette de la fonction pour choisir k, l et l'algo de recherche local, par Xavier.

# Cette fonction determine les entiers k et l d'ou sont applique la recherche locale, ainsi que l'algo de recherche locale a utiliser.
# k et l dependant de si on utilise OptA, OptB ou OptC et aussi de la sequence_courante (pour savoir ou sont les blocks de couleur).
# @param opt::Symbol : doit appartenir :OptA, :OptB, :OptC.
# @return k::UInt32, l::UInt32 , idLS::Symbol : idLS doit appartenir a global ID_LS. Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
function choisir_klLS(sequence_courrante::Array{Array{Int32,1},1}, opt::Symbol)
    #TODO : determiner les k et l en fonction de OptA, OptB et OptC et de la sequence courrante.
    return k, l, idLS
end
