# Fichier contenant toutes les fonction associées à la mutation d'une sequence
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1





# Fonction qui réalise une mutation sur une solution donnée
# @param enfant : l'enfant générer par le crossover
#       enfant[1] : Array{Array{Int,1},1} la sequence x
#       enfant[2] : Array{Array{Int,1},1} le tab violation associé à la sequence x
#       enfant[3][1] : Array{Int,1} le score sur les 3 obj
# @param objectif : l'objectif choisi (:pbl!, :hprio!, :lprio!) suivant l'obj qu'on focus
# @param inst : L'instance du problème étudié cf Util/instance.jl
# @param temps_mutation : le temps associé à une mutation
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @modify ::Array{Array{Array{Int,1},1},1} : L'enfant applique la mutation sur l'enfant
function mutation!(enfant::Array{Array{Array{Int,1},1},1}, objectif::Symbol, inst::Instance, temps_mutation::Float64 = 0.1, verbose::Bool = false, txtoutput::Bool = false)

    # Initialisation 
    obj = generateObj(objectif, inst)
    sz = size(enfant[1])[1]
    szcar = size(enfant[1][1])[1]
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
        for j in 1:length(enfant[3])
            println(string("Valeur sur l'objectif ", j, " : ", enfant[3][j]))
        end
        println("\n\n\n","3) Période des phases :","\n","   ------------------")
        for car in enfant[1]
            if (car[szcar-1]-car[szcar-2]+1)>pbl
                println(car)
                println(car[szcar-1]-car[szcar-2]+1)
            end
        end
        println(obj)
        println(timeOPT)
    end
    if txtoutput
        txt = string(txt, "2) Information sur la sequence initiale :\n","   ------------------------------------")
        for j in 1:length(enfant[3])
            txt = string(txt, "Valeur sur l'objectif ", j, " : ", enfant[3][j], "\n")
        end
        txt = string(txt, "\n\n\n","3) Période des phases :","\n","   ------------------")
    end


    nb = [0, 0, 0, 0]
    nb_effectiv = [0,0,0,0]
    debut = time()
    for Phase in 1:3
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

        while temps_mutation*(timeOPT[Phase]/100)>time()-debut
            f_rand, f_mouv = choisir_klLS(enfant[1], opt, obj, Phase)
            k, l = choose_f_rand(enfant[1], inst.ratio, enfant[2], f_rand, Phase, obj, inst.Hprio)

            effect = global_mouvement!(f_mouv, enfant[1], k, l, inst.ratio, enfant[2], inst.col_avant, inst.Hprio, obj, inst.pbl, f_rand)
            compteurMvt!(f_mouv, nb,nb_effectiv,effect)

            # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
            if verbose
                if (time()-debut)>(n/50)*temps_mutation*(timeOPT[Phase]/100)
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

        # affichage a chaque fin de phase :
        if txtoutput
            txt = string(txt, "\n\nPhase ", Phase, " :", "\n",
                "Nombre de swap : ",nb[1], "\n",
                "Nombre d'insertion : ",nb[2], "\n",
                "Nombre de reflection : ",nb[3], "\n",
                "Nombre de shuffle : ",nb[4], "\n",
            )
        end
        if verbose
            st_output=string(st_output, "#] ")
            println(st_output,100,"%")
            println("Nombre de swap : ",nb[1],", Nombre de swap_effectif : ",nb_effectiv[1])
            println("Nombre d'insertion : ",nb[2],", Nombre de insertion_effectif : ",nb_effectiv[2])
            println("Nombre de reflection : ",nb[3],", Nombre de reflection_effectif : ",nb_effectiv[3])
            println("Nombre de shuffle : ",nb[4],", Nombre de shuffle_effectif : ",nb_effectiv[4])
            a =evaluation(enfant[1],enfant[2],ratio_option,Hprio)
            println("score : ", a,"\n\n")
        end


        # Reset de nb
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
    end

    # Re evaluation en fin d'exection :
    a,b =evaluation_init(enfant[1], inst.sequence_j_avant, inst.ratio, inst.Hprio)
    enfant[3] = [a]

    if verbose
        println(a)
        for car in enfant[1]
            if (car[szcar-1]-car[szcar-2]+1)>pbl
                println(car)
                println(car[szcar-1]-car[szcar-2]+1)
            end
        end
    end

    return txt
end



function generateObj(objectif::Symbol, inst::Instance)
    obj = copy(inst.obj)
    alea = rand(1:2)
    if objectif == :pbl!
        obj[1] = 1
        if alea == 1
            obj[2] = 2
            obj[3] = 3
        else
            obj[3] = 2
            obj[2] = 3
        end
    elseif objectif == :hprio!
        obj[2] = 1
        if alea == 1
            obj[1] = 2
            obj[3] = 3
        else
            obj[3] = 2
            obj[1] = 3
        end
    elseif objectif == :lprio!
        obj[3] = 1
        if alea == 1
            obj[2] = 2
            obj[1] = 3
        else
            obj[1] = 2
            obj[2] = 3
        end
    end
    return obj
end
