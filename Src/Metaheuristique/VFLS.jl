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
=#



# Constantes utile pour fixer les types/opt :
const R = 1.05 # Macro-parametre : ratio de deterioration de solution accepte pour la recherche locale
const OPT = (:OptA, :OptB, :OptC) #Macro pour identifier les algos OptA, OptB et OptC
const ID_LS = (:swap!, :insertion!, :reflection!, :shuffle!) #Macro pour identifier les fonctions de LS



# Fonction principale de l'heuristique (VFLS)
# @param datas : Le jeux de données lu
# @param temps_max : Temps en milliseconde...
# @return : La meilleure sequence
function VFLS(datas::NTuple{4,DataFrame}, temps_max::Float64 = 1.0, verbose::Bool=true, txtoutput::Bool=true)
    # compute initial sequence :
    sequence_meilleure, score_init, tab_violation, ratio_option, Hprio, obj, pbl = compute_initial_sequence(datas)
    sz = size(sequence_meilleure)[1]
    szcar = size(sequence_meilleure[1])[1]
    timeOPT, opt = phases_init(obj)



    # affichage initial :
    if verbose
        println("1) Information sur les données :")
        println("   ---------------------------")
        println("Nombre d'options prioritaires : ", Hprio)
        println("PAINT_BATCH_LIMIT : ", pbl)
        println("Nombre de vehicules : ", sz)
        println("\n\n\n")
    end
    txt = ""
    if txtoutput
        txt = string(txt, "1) Information sur l'instance :\n",
                "   ----------------------------\n",
                "Nombre d'options prioritaires : ", Hprio, "\n",
                "PAINT_BATCH_LIMIT : ", pbl, "\n",
                "Nombre de vehicules : ", sz, "\n",
                "\n\n\n")
    end



    # affichage initial sequence :
    if verbose
        println("2) Information sur la sequence initiale :")
        println("   ------------------------------------")
        for j in 1:length(score_init)
            println(string("Valeur sur l'objectif ", j, " : ", score_init[j]))
        end
        println("\n\n\n","3) Période des phases :","\n","   ------------------")
    end
    if txtoutput
        txt = string(txt, "2) Information sur la sequence initiale :\n","   ------------------------------------")
        for j in 1:length(score_init)
            txt = string(txt, "Valeur sur l'objectif ", j, " : ", score_init[j], "\n")
        end
        txt = string(txt, "\n\n\n","3) Période des phases :","\n","   ------------------")
    end


    nb = [0, 0, 0, 0]
    debut = time()
    @time for Phase in 1:3
        while temps_max*(timeOPT[Phase]/100)>time()-debut
            f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
            typeof(f_mouv)
            k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
            compteurMvt!(f_mouv, nb)
            # global_mouvement!()
            swap!(sequence_meilleure,k,l,ratio_option,tab_violation,Hprio,obj,pbl,:generic!)
        end

        # affichage a chaque fin de phase :
        if txtoutput
            txt = string(txt, "\nPhase ", Phase, " :", "\n",
                "Nombre de swap : ",nb[1], "\n",
                "Nombre d'insertion : ",nb[2], "\n",
                "Nombre de reflection : ",nb[3], "\n",
                "Nombre de shuffle : ",nb[4], "\n",
            )
        end
        if verbose
            println("Phase ", Phase, " :")
            println("Nombre de swap : ",nb[1])
            println("Nombre d'insertion : ",nb[2])
            println("Nombre de reflection : ",nb[3])
            println("Nombre de shuffle : ",nb[4])
        end


        # Reset de nb
        nb = [0, 0, 0, 0]
    end

    # Re evaluation en fin d'exection :
    a, b =evaluation_init(sequence_meilleure,ratio_option,Hprio)


    return a, b, txt
end



# Fonction qui realise une comparaison lexicographique
# @param score_courrant : Le score courant comparer à
# @pram score_meilleur : le meilleur score
# @return ::Bool : true si le courrant est mieux
function estMieux(score_courrant::Array{Int64,1}, score_meilleur::Array{Int64,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end



# Fonction qui compte le nombre de mouvements réalisés
# @param f_mouv : le type de mouvement
# @param nb : le compteur
# @modify nb : mets à jour nb
function compteurMvt!(f_mouv::Symbol, nb::Array{Int, 1})
    if f_mouv==:swap!
        nb[1]+=1
    elseif f_mouv==:insertion!
        nb[2]+=1
    elseif f_mouv==:reflection!
        nb[3]+=1
    else
        nb[4]+=1
    end
    nothing
end
