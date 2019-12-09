# Fichier contenant la fonction pour generer une population delite
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 2



# Fonction qui génère et renvois la population élite
# @param temps_firstind : le temps pour la phase commune à toutes les sol elites (et la premiere entre autre)
# @param temps_elites : le temps pour les 5 autres solutions elites
# @param sequence_meilleure : la sequence de base pour creer les sol elites
# @param Ratio x/y : Les ratio avec [1] = x
#                   Les ratio avec [2] = y
# @param pbl : Le paint batch limit
# @param obj : Les obj des l'ordre
# @param Hprio : le nombre de Hprio
# @return Array{Array{Array{Array{Int,1},1},1},1} : la population elite, cf generate.jl pour voir comment on considère la population
function pop_elites(temps_firstind::Float64, temps_elites::Float64,sequence_meilleure::Array{Array{Int,1},1},ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}} , Hprio::Int, pbl::Int)
    # compute initial sequence :

    debut = time()
    obj = [1,2,3]
    timeOPT, opt = phases_init(obj)
    @time for Phase in 1:3
        debut = time()

        while temps_firstind*(timeOPT[Phase]/100)>time()-debut
            f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
            k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
            effect = global_mouvement!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand)
        end
    end
    a = evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)
    tab_pop = [[sequence_meilleure,tab_violation, [a]]]
    sequence_best = deepcopy(sequence_meilleure)
    tab_violation_best =  deepcopy(tab_violation)


    OBJ = [[1,3,2],[2,1,3],[3,1,2],[2,3,1],[3,2,1]]
    for objectif in OBJ
        obj = objectif
        timeOPT, opt = phases_init(obj)
        sequence_meilleure= deepcopy(sequence_best)
        tab_violation = deepcopy(tab_violation_best)
        debut = time()
        @time for Phase in 1:3
            debut = time()
            while temps_elites*(timeOPT[Phase]/100)>time()-debut

                f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
                k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
                effect = global_mouvement!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand)
            end
        end
        a = evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)
        append!(tab_pop,[[deepcopy(sequence_meilleure),deepcopy(tab_violation), [a]]])
    end

    return tab_pop
end
