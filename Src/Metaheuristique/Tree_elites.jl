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
#const R = 1.05 # Macro-parametre : ratio de deterioration de solution accepte pour la recherche locale
#const OPT = (:OptA, :OptB, :OptC) #Macro pour identifier les algos OptA, OptB et OptC
#const ID_LS = (:swap!, :insertion!, :reflection!, :shuffle!) #Macro pour identifier les fonctions de LS



# Fonction principale de l'heuristique (VFLS)
# @param datas : Le jeux de données lu
# @param temps_max : Temps en milliseconde...
# @return : La meilleure sequence
function Tree_elites(datas::NTuple{4,DataFrame}, temps_max::Float64 = 1.0, verbose::Bool=true, txtoutput::Bool=true)
    # compute initial sequence :
    sequence_meilleure,sequence_avant, score_init, tab_violation , ratio_option, Hprio, obj, pbl = compute_initial_sequence_2(datas)
    sz = size(sequence_meilleure)[1]
    szcar = size(sequence_meilleure[1])[1]
    println(obj)
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
    nb_effectiv = [0,0,0,0]
    debut = time()
    temps_max=600
    obj = [1,2,3]
    println(timeOPT)
    @time for Phase in 1:3
        debut = time()

        # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
        if verbose
            n=0
            st_output = string("Phase : ",Phase ,", Execution : [")
            tmp_st = ""
            for i in 1:50-n-1
                tmp_st=string(tmp_st," ")
            end
            tmp_st=string(tmp_st,"   ] ")
        end

        while temps_max*(timeOPT[Phase]/100)>time()-debut

            f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
            k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
            effect = global_mouvement!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand)
            compteurMvt!(f_mouv, nb,nb_effectiv,effect)

            # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
            if verbose
                if (time()-debut)>(n/50)*temps_max*(timeOPT[Phase]/100)
                    st_output=string(st_output, "#")
                    tmp_st = ""
                    for i in 1:50-n-1
                        tmp_st=string(tmp_st," ")
                    end
                    tmp_st=string(tmp_st," ] ")
                    print(st_output,tmp_st,n*2,"% \r")
                    n+=1
                end
            end
        end
        for car in sequence_meilleure
            if car[szcar-1]-car[szcar-2]>pbl
                println(car)
            end
        end

        # affichage a chaque fin de phase :
        if txtoutput
            txt = string(txt, "\n\nPhase ", Phase, " :", "\n",
                "Nombre de swap : ",nb[1], "\n",
                "Nombre d'insertion : ",nb[2], "\n",
                "Nombre de reflection : ",nb[3], "\n",
                "Nombre de shuffle : ",nb[4], "\n",
            )
        end
        for car in sequence_meilleure
            #println(car)
        end
        if verbose
            st_output=string(st_output, "#] ")
            println(st_output,100,"%")
            #println("\nPhase ", Phase, " :")
            println("Nombre de swap : ",nb[1],", Nombre de swap_effectif : ",nb_effectiv[1])
            println("Nombre d'insertion : ",nb[2],", Nombre de insertion_effectif : ",nb_effectiv[2])
            println("Nombre de reflection : ",nb[3],", Nombre de reflection_effectif : ",nb_effectiv[3])
            println("Nombre de shuffle : ",nb[4],", Nombre de shuffle_effectif : ",nb_effectiv[4])
            a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
            println("score : ", a,"\n\n")
        end


        # Reset de nb
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
    end

    # Re evaluation en fin d'exection :
    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)

    println(a)

    col = sequence_meilleure[1][2]
    deb = sequence_meilleure[1][szcar-2]
    fin = sequence_meilleure[1][szcar-1]
    for i in 1:1:size(sequence_meilleure)[1]

        if col !=  sequence_meilleure[i][2]
            col = sequence_meilleure[i][2]
            if fin+1 != sequence_meilleure[i][szcar-2]
                for car in sequence_meilleure
                    println(car)
                end
                println("k : ",k, " l : ", l)
                println(sequence_meilleure[k])
                println(sequence_meilleure[l])
                println(i)

                return FAUX
            end
            deb = sequence_meilleure[i][szcar-2]
            fin = sequence_meilleure[i][szcar-1]
        else
            if fin != sequence_meilleure[i][szcar-1] || deb != sequence_meilleure[i][szcar-2]

                for car in sequence_meilleure
                    println(car)
                end
                println("k : ",k, " l : ", l)
                println(sequence_meilleure[k])
                println(sequence_meilleure[l])

                return FAUXXXXX
            end
        end
        if deb<1 || fin >sz
            println("k : ",k, " l : ", l)
            println(sequence_meilleure[k])
            println(sequence_meilleure[l])
            println(i)
            println(sequence_meilleure[i])

            return FAUX_fin_ou_deb

        end
    end
    sequence_best = deepcopy(sequence_meilleure)
    tab_violation_best =  deepcopy(tab_violation)


    OBJ = [[1,3,2],[2,3,1],[2,1,3],[3,2,1],[3,1,2]]
    for objectif in OBJ
        obj = objectif
        sequence_meilleure= deepcopy(sequence_best)
        tab_violation = deepcopy(tab_violation_best)
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
        debut = time()
        temps_max=200
        @time for Phase in 1:3
            debut = time()

            # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
            if verbose
                n=0
                st_output = string("Phase : ",Phase ,", Execution : [")
                tmp_st = ""
                for i in 1:50-n-1
                    tmp_st=string(tmp_st," ")
                end
                tmp_st=string(tmp_st,"   ] ")
            end

            while temps_max*(timeOPT[Phase]/100)>time()-debut

                f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
                k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
                effect = global_mouvement!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand)
                compteurMvt!(f_mouv, nb,nb_effectiv,effect)

                # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
                if verbose
                    if (time()-debut)>(n/50)*temps_max*(timeOPT[Phase]/100)
                        st_output=string(st_output, "#")
                        tmp_st = ""
                        for i in 1:50-n-1
                            tmp_st=string(tmp_st," ")
                        end
                        tmp_st=string(tmp_st," ] ")
                        print(st_output,tmp_st,n*2,"% \r")
                        n+=1
                    end
                end
            end
            for car in sequence_meilleure
                if car[szcar-1]-car[szcar-2]>pbl
                    println(car)
                end
            end

            # affichage a chaque fin de phase :
            if txtoutput
                txt = string(txt, "\n\nPhase ", Phase, " :", "\n",
                    "Nombre de swap : ",nb[1], "\n",
                    "Nombre d'insertion : ",nb[2], "\n",
                    "Nombre de reflection : ",nb[3], "\n",
                    "Nombre de shuffle : ",nb[4], "\n",
                )
            end
            for car in sequence_meilleure
                #println(car)
            end
            if verbose
                st_output=string(st_output, "#] ")
                println(st_output,100,"%")
                #println("\nPhase ", Phase, " :")
                println("Nombre de swap : ",nb[1],", Nombre de swap_effectif : ",nb_effectiv[1])
                println("Nombre d'insertion : ",nb[2],", Nombre de insertion_effectif : ",nb_effectiv[2])
                println("Nombre de reflection : ",nb[3],", Nombre de reflection_effectif : ",nb_effectiv[3])
                println("Nombre de shuffle : ",nb[4],", Nombre de shuffle_effectif : ",nb_effectiv[4])
                a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
                println("score : ", a,"\n\n")
            end


            # Reset de nb
            nb = [0, 0, 0, 0]
            nb_effectiv = [0,0,0,0]
        end

        # Re evaluation en fin d'exection :
        a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)

        println(a)

        col = sequence_meilleure[1][2]
        deb = sequence_meilleure[1][szcar-2]
        fin = sequence_meilleure[1][szcar-1]
        for i in 1:1:size(sequence_meilleure)[1]

            if col !=  sequence_meilleure[i][2]
                col = sequence_meilleure[i][2]
                if fin+1 != sequence_meilleure[i][szcar-2]
                    for car in sequence_meilleure
                        println(car)
                    end
                    println("k : ",k, " l : ", l)
                    println(sequence_meilleure[k])
                    println(sequence_meilleure[l])
                    println(i)

                    return FAUX
                end
                deb = sequence_meilleure[i][szcar-2]
                fin = sequence_meilleure[i][szcar-1]
            else
                if fin != sequence_meilleure[i][szcar-1] || deb != sequence_meilleure[i][szcar-2]

                    for car in sequence_meilleure
                        println(car)
                    end
                    println("k : ",k, " l : ", l)
                    println(sequence_meilleure[k])
                    println(sequence_meilleure[l])

                    return FAUXXXXX
                end
            end
            if deb<1 || fin >sz
                println("k : ",k, " l : ", l)
                println(sequence_meilleure[k])
                println(sequence_meilleure[l])
                println(i)
                println(sequence_meilleure[i])

                return FAUX_fin_ou_deb

            end
        end
    end
    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
    println(a)
    return a, sequence_meilleure, txt
end
