# Fonction principale de l'heuristique, par Xavier

include("choisir_klLS.jl")

const R = 1.05 # Macro-parametre : ratio de deterioration de solution accepte pour la recherche locale
const OPT = (:OptA, :OptB, :OptC) #Macro pour identifier les algos OptA, OptB et OptC
const ID_LS = (:swap!, :fw_insertion!, :bw_insertion!, :reflection!, :permutation!) #Macro pour identifier les fonctions de LS

function VFLS(data, temps_max::Float32 = 10.0)
    sequence_courrante::Array{Array{Int32,1},1} = init_sequence(data) #Le glouton
    score_courrant::Array{Int32,1} = evaluation_init(sequence_courrante) #Score = tableaux des scores des 3 objectifs respectifs.
    sequence_meilleure = deepcopy(sequence_courrante)
    score_meilleur = deepcopy(score_courrant)
    debut = time()
    global OPT
    while temps_max > time() - debut
        for opt in OPT
            local k::UInt32, l::UInt32, LSfoo::Function = choisir_klLS(sequence_courrante, opt) #Choix des param de la LS
            LSfoo(sequence_courrante, k, l, score_courrant) #Appel de la fonction de nom (Symbol) LS
            if estMieux(score_courrant, score_meilleur)
                sequence_meilleure = deepcopy(sequence_courrante)
                score_meilleur = deepcopy(sequence_courrante)
            end
        end
    return sequence_meilleure
end

function estMieux(score_courrant::Array{Int32,1}, score_meilleur::Array{Int32,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end
