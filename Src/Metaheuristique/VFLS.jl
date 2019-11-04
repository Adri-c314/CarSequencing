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
function VFLS(datas::NTuple{4,DataFrame}, temps_max::Float64 = 10.0)
    # compute initial sequence :
    ## stop enlever des trucs important 2 fois que je fais ça............
    ## on a besoin des ratio et de Hprio et obj sinon pour phases_init c'est plus compmiqué quoi......
    sequence_meilleure, score_meilleur, tab_violation, ratio_option, Hprio, obj,pbl = compute_initial_sequence(datas)
    timeOPT, opt = phases_init(obj)
    println(score_meilleur)
    # while temps_max is not reached do
    debut = time()
    sz = size(sequence_meilleure)[1]
    szcar = size(sequence_meilleure[1])[1]
    nb = [0,0,0,0]
    @time for Phase in 1:3
        while temps_max*(timeOPT[Phase]/100)>time()-debut
        #for i in 1:100
            ID_LS = (:swap!, :insertion!, :reflection!, :shuffle!)


            f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt,obj,Phase)

            k,l = choose_f_rand(sequence_meilleure,ratio_option,tab_violation,f_rand,Phase,obj,Hprio)

            if f_mouv==:swap!
                swap!(sequence_meilleure,k,l,score_meilleur,ratio_option,tab_violation,Hprio,obj,pbl,f_rand)
                nb[1]+=1
            elseif f_mouv==:insertion!
                nb[2]+=1
            elseif f_mouv==:reflection!
                nb[3]+=1
                ##fonctionne pas
                #reflection(sequence_meilleure,k,l,score_meilleur,ratio_option,tab_violation,Hprio,obj,pbl,f_rand)
            else
                nb[4]+=1
                ## fonctionne mal sur pbl je corrige ça
                #shuffle_(sequence_meilleure,score_meilleur,ratio_option,tab_violation,Hprio,obj,pbl)
            end
            #println(nb)
            #swap!(sequence_meilleure,k,l,score_meilleur,ratio_option,tab_violation,Hprio,obj,pbl,:generic!)
            #shuffle_(sequence_meilleure,score_meilleur,ratio_option,tab_violation,Hprio,obj,pbl)
            #=
            k, l, LSfoo! = choisir_klLS(sequence_meilleure, opt) # choose transformation and positions where applying it;
            if global_test_mouvement!(LSfoo!, sequence_meilleure, score_meilleur, k, l) # if transformation is good then
                global_mouvement!(LSfoo!, sequence_meilleure, k, l) # update current sequence by performing it;
            end
            =#
        end
    end

    a , b =evaluation_init(sequence_meilleure,ratio_option,Hprio)
    szcar = size(sequence_meilleure[1])[1]
    for car in sequence_meilleure
        println(car)
    end
    println("_____________________")
    println(nb)
    println(a)
    return sequence_meilleure
end


# Fonction qui realise une comparaison lexicographique
# @param score_courrant : Le score courant comparer à
# @pram score_meilleur : le meilleur score
# @return ::Bool : true si le courrant est mieux
function estMieux(score_courrant::Array{Int32,1}, score_meilleur::Array{Int32,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end
