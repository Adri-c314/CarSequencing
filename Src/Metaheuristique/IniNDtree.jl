


function IniNDtree(datas::NTuple{4,DataFrame}, verbose::Bool=true, txtoutput::Bool=true)
    # compute initial sequence :
    sequence_meilleure::Array{Array{Int,1},1},sequence_avant, score_init, tab_violation::Array{Array{Int,1},1}  , ratio_option, Hprio, obj, pbl = compute_initial_sequence_2(datas)
    sz = size(sequence_meilleure)[1]
    szcar = size(sequence_meilleure[1])[1]
    obj = [1,2,3]
    timeOPT, opt = phases_init(obj)


    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
    NDtree = Sommet()
    maj!(NDtree, (sequence_meilleure,a,tab_violation))

    nb = [0, 0, 0, 0]
    nb_effectiv = [0,0,0,0]
    debut = time()
    temps_max=600


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

    maj!(NDtree, (sequence_meilleure,a,tab_violation))
    sequence_best = deepcopy(sequence_meilleure)
    tab_violation_best =  deepcopy(tab_violation)

    temps_max=200
    OBJ = [[1,3,2],[2,3,1],[2,1,3],[3,2,1],[3,1,2]]
    for objectif in OBJ
        obj = objectif
        timeOPT, opt = phases_init(obj)
        sequence_meilleure= deepcopy(sequence_best)
        tab_violation = deepcopy(tab_violation_best)
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
        debut = time()
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
                if effect
                    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
                    maj!(NDtree, (sequence_meilleure,a,tab_violation))
                end
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

    end

    pareto_tmp = get_solutions(NDtree)
    for i in pareto_tmp
        println(i[2])
    end
    temps_max=30

    sequence_best= deepcopy(sequence_meilleure)
    tab_violation_best =  deepcopy(tab_violation)
    for par in pareto_tmp
        sequence_meilleure = deepcopy(par[1])
        tab_violation=  deepcopy(par[3])

        sortie  = false
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
                effect = global_mouvement_3!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand)
                compteurMvt!(f_mouv, nb,nb_effectiv,effect)

                if effect
                    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
                    maj!(NDtree, (sequence_meilleure,a,tab_violation))
                    sortie = true
                end
                # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
                if sortie
                    break
                end
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
            if sortie
                break
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
    end
    pareto_tmp = get_solutions(NDtree)
    for i in pareto_tmp
        println(i[2])
    end
    temps_max=20
    sequence_best = deepcopy(sequence_meilleure)
    tab_violation_best =  deepcopy(tab_violation)
    for par in pareto_tmp
        sequence_meilleure = deepcopy(par[1])
        tab_violation =  deepcopy(par[3])
        @time for Phase in 1:3
            debut = time()

            while temps_max*(timeOPT[Phase]/100)>time()-debut

                f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
                k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
                effect = global_mouvement_3!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand)
                if effect
                    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
                    maj!(NDtree, (sequence_meilleure,a,tab_violation))
                end
                # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
                sequence_meilleure = deepcopy(par[1])
                tab_violation =  deepcopy(par[3])
            end

        end
    end

    pareto_tmp = get_solutions(NDtree)
    println(size(pareto_tmp)[1])
    for i in pareto_tmp
        println(i[2])
    end
    plot_pareto(pareto_tmp)
    return a, sequence_meilleure, txt
end
