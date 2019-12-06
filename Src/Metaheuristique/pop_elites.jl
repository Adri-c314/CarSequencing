# Fichier contenant la fonction VFLS, fonction principale de l'heuristique
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 2



#=
## Instance : les voitures avec [1]= leur place mais pas utlie en vrai
##            les voitures avec [2]= leurs couleurs
##            les voitures avec [3:3+Hprio]= leurs Hprio (ca serait pas plutot [3:3+Hprio-1] ?)
##            les voitures avec [3+Hprio:]= leurs Lprio
##                              [size()[1]-2] = le debut de leur sequence de couleur
##                              [size()[1]-1] = la fin de leur sequence de couleur
##                              [size()[1]] : l'ordre initial
## Ratio x/y: Les ratio avec [1] = x
##            Les ratio avec [2] = y
## pbl      : Le paint batch limit
## obj      : Les obj des l'ordre
## Hprio    : le nombre de Hprio
## return 6 individu elites
=#
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
    tab_pop = [[sequence_meilleure,tab_violation]]
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
        append!(tab_pop,[[deepcopy(sequence_meilleure),deepcopy(tab_violation)]])
    end

    return tab_pop
end
