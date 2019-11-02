# Fichier contenant la fonction VFLS, fonction principale de l'heuristique
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 2



# Constantes utile pour fixer les types/opt :
const R = 1.05 # Macro-parametre : ratio de deterioration de solution accepte pour la recherche locale
const OPT = (:OptA, :OptB, :OptC) #Macro pour identifier les algos OptA, OptB et OptC
const ID_LS = (:swap!, :fw_insertion!, :bw_insertion!, :reflection!, :permutation!) #Macro pour identifier les fonctions de LS



# Fonction principale de l'heuristique (VFLS)
# @param datas : Le jeux de données lu
# @param temps_max : Temps en milliseconde...
# @return : La meilleure sequence
function VFLS(datas, temps_max::Float64 = 1000.0)
    # compute initial sequence :
    sequence_meilleure, score_meilleur, tab_violation = compute_initial_sequence(datas)
    timeOPT, opt = phases_init()

    # while temps_max is not reached do
    debut = time()
    Phase = 0

    while temps_max > time() - debut
        Phase = Phase + 1
        while temps_max*(timeOPT[Phase]/100)>time()-debut
            #=
            k, l, LSfoo! = choisir_klLS(sequence_meilleure, opt) # choose transformation and positions where applying it;
            if global_test_mouvement!(LSfoo!, sequence_meilleure, score_meilleur, k, l) # if transformation is good then
                global_mouvement!(LSfoo!, sequence_meilleure, k, l) # update current sequence by performing it;
            end
            =#
        end
    end

    return sequence_meilleure
end



# Fonction qui realise une comparaison lexicographique
# @param score_courrant : Le score courant comparer à
# @pram score_meilleur : le meilleur score
# @return ::Bool : true si le courrant est mieux
function estMieux(score_courrant::Array{Int32,1}, score_meilleur::Array{Int32,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end
