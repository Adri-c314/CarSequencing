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
    timeOPT, OPT = phases_init()

    # while temps_max is not reached do
    debut = time()
    Phase = 0
    while temps_max > time() - debut
        # choose transformation and positions where applying it;
        # if transformation is good then
        #    update current sequence by performing it;
        # end if;
        Phase = Phase + 1
        while temps_max*(timeOPT[Phase]/100)>time()-debut
            # realisation de la phase Phase
        end
    end

    #=while temps_max > time() - debut
        ##a faire car on passe pas le meme temps sur chaque opt en fonction des objectifs donc pas un for mais un while 3 fois
        for opt in OPT
            local k::UInt32, l::UInt32, LSfoo!::Function = choisir_klLS(sequence_courrante, opt) #Choix des param de la LS.
            LSfoo!(sequence_courrante, k, l, score_courrant) #Appel de la fonction de recherche locale.
            if estMieux(score_courrant, score_meilleur)
                sequence_meilleure = deepcopy(sequence_courrante)
                score_meilleur = deepcopy(sequence_courrante)
            end
        end

    end=#

    return sequence_meilleure
end



# Fonction qui realise une comparaison lexicographique
# @param score_courrant : Le score courant comparer à
# @pram score_meilleur : le meilleur score
# @return ::Bool : true si le courrant est mieux
function estMieux(score_courrant::Array{Int32,1}, score_meilleur::Array{Int32,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end
