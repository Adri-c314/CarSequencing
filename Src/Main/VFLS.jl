# Fonction principale de l'heuristique, par Xavier

const R = 1.05 # Macro-parametre : ratio de deterioration de solution accepte pour la recherche locale
const OPT = (:OptA, :OptB, :OptC) #Macro pour identifier les algos OptA, OptB et OptC
const ID_LS = (:swap!, :fw_insertion!, :bw_insertion!, :reflection!, :permutation!) #Macro pour identifier les fonctions de LS

function VFLS(data, temps_max::Float64 = 10.0)
    sequence_courrante = init_sequence(data) #Le glouton
    score_courrant::Array{Int32,1} = evaluation_init(sequence_courrante) #Score = tableaux des scores des 3 objectifs respectifs.
    sequence_meilleure = deepcopy(sequence_courrante)
    score_meilleur = deepcopy(score_courrant)
    debut = time()
    global OPT
    while temps_max > time() - debut
        for opt in OPT
            local k::UInt32, l::UInt32, idLS::Symbol = choisir_klLS(sequence_courrante, opt) #Choix des param de la LS
            getfield(Main, idLS)(sequence_courrante, k, l, score_courrant) #Appel de la fonction de nom (Symbol) LS
            if estMieux(score_courrant, score_meilleur)
                sequence_meilleure = deepcopy(sequence_courrante)
                score_meilleur = deepcopy(sequence_courrante)
            end
        end
    return sequence_meilleure
end

function swap!(sequence_courrante, k::UInt32, l::UInt32, score_courrant::Array{Int32,1})
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end

function fw_insertion!(sequence_courrante, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end

function bw_insertion!(sequence_courrante, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end

function reflection!(sequence_courrante, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end

function permutation!(sequence_courrante, score_courrant::Array{Int32,1}, k::UInt32, l::UInt32)
    #TODO : Effectuer la recherche locale
    #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
    nothing # Pas de return pour eviter les copies de memoire.
end

function estMieux(score_courrant::Array{Int32,1}, score_meilleur::Array{Int32,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end

# @param opt::Symbol : doit appartenir :OptA, :OptB, :OptC.
# @return k::UInt32, l::UInt32 , idLS::Symbol : idLS doit appartenir a global ID_LS. Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
function choisir_klLS(sequence_courrante, opt::Symbol)
    #TODO : determiner les k et l en fonction de OptA, OptB et OptC et de la sequence courrante.
    return k, l , idLS
end
