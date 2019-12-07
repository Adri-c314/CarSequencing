


function IniNDtree(datas::NTuple{4,DataFrame}, verbose::Bool=true, txtoutput::Bool=true)
    # compute initial sequence :
    sequence_meilleure::Array{Array{Int,1},1},sequence_avant, score_init, tab_violation::Array{Array{Int,1},1}  , ratio_option, Hprio, obj, pbl = compute_initial_sequence_2(datas)
    sz = size(sequence_meilleure)[1]
    szcar = size(sequence_meilleure[1])[1]
    obj = [1,2,3]
    timeOPT, opt = phases_init(obj)
    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
    NDtree = Sommet()
    maj!(NDtree, (deepcopy(sequence_meilleure),deepcopy(a),deepcopy(tab_violation)))
    debutall = time()
    temps_all = 300
    nb = [0, 0, 0, 0]
    nb_effectiv = [0,0,0,0]
    debut = time()
    temps_max=60


    ## first solution
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

    ## tapisse les solutions efficaces
    maj!(NDtree, (deepcopy(sequence_meilleure),deepcopy(a),deepcopy(tab_violation)))
    sequence_best = deepcopy(sequence_meilleure)
    tab_violation_best =  deepcopy(tab_violation)
    temps_max=20
    OBJ = [[1,3,2],[2,3,1],[2,1,3],[3,2,1],[3,1,2]]
    for objectif in OBJ
        pareto_tmp = get_solutions(NDtree)
        tmp1 =pareto_tmp[1][2][1]
        tmp2 =pareto_tmp[1][2][2]
        tmp3 =pareto_tmp[1][2][3]
        tmp = [tmp1,tmp2,tmp3]
        tmpi= 1
        ii=1
        for pareto in pareto_tmp
            if tmp[objectif[1]]>pareto[2][objectif[1]] || (tmp[objectif[1]]==pareto[2][objectif[1]] && tmp[objectif[2]]>pareto[2][objectif[2]]) ||(tmp[objectif[1]]==pareto[2][objectif[1]] && tmp[objectif[2]]==pareto[2][objectif[2]]&& tmp[objectif[3]]>pareto[2][objectif[3]])
                tmp = pareto[2]
                tmpi=ii
            end
            ii+=1
        end

        obj = objectif
        timeOPT, opt = phases_init(obj)
        sequence_meilleure= deepcopy(pareto_tmp[tmpi][1])
        tab_violation = deepcopy(pareto_tmp[tmpi][3])
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
                    maj!(NDtree, (deepcopy(sequence_meilleure),deepcopy(a),deepcopy(tab_violation)))
                end
                # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
            end

            # Reset de nb
            nb = [0, 0, 0, 0]
            nb_effectiv = [0,0,0,0]
        end
    end
    timeOPT, opt = phases_init([2,1,3])
    pareto_tmp = get_solutions(NDtree)
    temps_max=10
    score_nadir = nadir_global(NDtree)
    println("Nadir : ",score_nadir)
    for par in pareto_tmp
        sequence_meilleure = deepcopy(par[1])
        b = deepcopy(par[2])
        tab_violation=  deepcopy(par[3])
        a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
        println(a)
        println(b)
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
        sortie  = false
        @time for Phase in 1:3
            debut = time()
            while temps_max*(timeOPT[Phase]/100)>time()-debut

                f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
                k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
                effect = global_mouvement_3!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand,a,score_nadir)
                compteurMvt!(f_mouv, nb,nb_effectiv,effect)
                if effect
                    a =evaluation(sequence_meilleure,tab_violation,ratio_option ,Hprio)
                    maj!(NDtree, (deepcopy(sequence_meilleure),deepcopy(a),deepcopy(tab_violation)))
                    sortie = true
                end
                # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
                if sortie
                    break
                end
            end
            if sortie
                break
            end
        end
    end
    pareto_tmp = get_solutions(NDtree)
    ## le PLS
    OBJ = [[1,2,3],[1,3,2],[2,3,1],[2,1,3],[3,2,1],[3,1,2]]
    while size(pareto_tmp)[1]>1 && temps_all>time()-debutall

        obj = OBJ[rand(1:6)]
        timeOPT, opt = phases_init(obj)
        println(size(pareto_tmp)[1])
        temps_max=30
        pareto1_tmp = get_solutions(NDtree)
        score_nadir = nadir_global(NDtree)
        for par in pareto_tmp
            if temps_all>time()-debutall
                break
            end
            sequence_meilleure = deepcopy(par[1])
            tab_violation=  deepcopy(par[3])
            a =  deepcopy(par[2])

            @time for Phase in 1:3
                debut = time()
                while temps_max*(timeOPT[Phase]/100)>time()-debut

                    f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
                    k, l = choose_f_rand(sequence_meilleure, ratio_option, tab_violation, f_rand, Phase, obj, Hprio)
                    effect = global_mouvement_3!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation , Hprio, obj, pbl, f_rand,a,score_nadir)
                    if effect
                        maj!(NDtree, (deepcopy(sequence_meilleure),deepcopy(a),deepcopy(tab_violation)))
                    end
                end
            end
        end
        pareto_tmp2 = get_solutions(NDtree)
        secondpareto=[pareto_tmp2[1]]
        for pareto2 in pareto_tmp2
            tmpcond = true
            for pareto in pareto1_tmp
                if pareto[2][1]==pareto2[2][1]&&pareto[2][2]==pareto2[2][2]&&pareto[2][3]==pareto2[2][3]
                    tmpcond = false
                end
            end
            if tmpcond
                append!(secondpareto,[pareto2])
            end
        end
        pareto_tmp = secondpareto
    end
    println("FIN")
    pareto_tmp = get_solutions(NDtree)
    println("hyper : ", hypervolume(NDtree))
    println("nadir : ",nadir_global(NDtree))
    return [p[2] for p in pareto_tmp]
end
