# Fonction principale de l'heuristique, par Xavier.

include("choisir_klLS.jl")
include("fonction_moche_mais_j_ai_la_flemme.jl")

const R = 1.05 # Macro-parametre : ratio de deterioration de solution accepte pour la recherche locale
const OPT = (:OptA, :OptB, :OptC) #Macro pour identifier les algos OptA, OptB et OptC
const ID_LS = (:swap!, :fw_insertion!, :bw_insertion!, :reflection!, :permutation!) #Macro pour identifier les fonctions de LS
## temps en milliseconde...
function VFLS(instance,reference, temps_max::Float64 = 1000.0)
    sequence::Array{Array{Int32,1},1},prio::Array{Array{Int32,1},1},pbl::Int32,obj::Array{Int32,1},Hprio::Int32 = init_sequence(instance,reference) #Le glouton.
    if obj[1]==1
        sequence_courrante = GreedyRAF(sequence,prio,pbl,Hprio)
    else
        sequence_courrante = GreedyEP(sequence,prio,pbl,Hprio)
    end
    score_courrant::Array{Int32,1},tab_violation::Array{Array{Int32,1},1} = evaluation_init(sequence_courrante,prio,Hprio) #Score = tableaux des scores des 3 objectifs respectifs.
    sequence_meilleure = deepcopy(sequence_courrante)
    score_meilleur = deepcopy(score_courrant)
    debut = time()
    timeOPT = [0,0,0] ## le temps accordé pour chaque phase
    OPT = [0,0,0]   ## l'opt utilisé pour chaque phase avec 1=A,2=B,3=C
    if obj[1]==2
        if obj[3]!=0
            timeOPT= [60,25,15]
            if(obj[2]==1)
                OPT= [1,1,2]
            else
                OPT= [1,2,3]
            end
        else
            timeOPT= [50,50,0]
            OPT= [1,2,0]
        end
    else
        if obj[3]!=0
            timeOPT= [80,20,0]
            OPT[3,3,0]
        else
            timeOPT= [100,0,0]
            OPT = [3,0,0]
        end
    end
    ##Phase 1
    Phase = 1
    while temps_max*(timeOPT[Phase]/100)>time()-debut

    end
    ##Phase 2
    Phase = 2
    while temps_max*(timeOPT[Phase]/100)>time()-debut

    end

    ##Phase 3
    Phase = 3
    while temps_max*(timeOPT[Phase]/100)>time()-debut

    end

    while temps_max > time() - debut



        ##a faire car on passe pas le meme temps sur chaque opt en fonction des objectifs donc pas un for mais un while 3 fois
        #=for opt in OPT
            local k::UInt32, l::UInt32, LSfoo!::Function = choisir_klLS(sequence_courrante, opt) #Choix des param de la LS.
            LSfoo!(sequence_courrante, k, l, score_courrant) #Appel de la fonction de recherche locale.
            if estMieux(score_courrant, score_meilleur)
                sequence_meilleure = deepcopy(sequence_courrante)
                score_meilleur = deepcopy(sequence_courrante)
            end
        end
        =#
    end
    return sequence_meilleure
end

function estMieux(score_courrant::Array{Int32,1}, score_meilleur::Array{Int32,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end
