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
# @param temps_max : Temps max d'execution (en seconde)
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
# @return : La meilleure sequence
function VFLS(datas::NTuple{4,DataFrame}, temps_max::Float64 = 1.0, verbose::Bool=false, txtoutput::Bool=true)
    # compute initial sequence :
    sequence_meilleure,sequence_avant, score_init, tab_violation , ratio_option, Hprio, obj, pbl = compute_initial_sequence_2(datas)
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
        println(obj)
        println(timeOPT)
    end
    if txtoutput
        txt = string(txt, "2) Information sur la sequence initiale :\n","   ------------------------------------\n")
        for j in 1:length(score_init)
            txt = string(txt, "Valeur sur l'objectif ", j, " : ", score_init[j], "\n")
        end
        txt = string(txt, "\n\n\n","3) Période des phases :","\n","   ------------------")
    end
    for car in sequence_meilleure
        if car[szcar-1]-car[szcar-2]>pbl
            println("trop long")
        end
    end
    nb = [0, 0, 0, 0]
    nb_effectiv = [0,0,0,0]
    debut = time()
    a = evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)

    if verbose
        println("score : ", a,"\n\n")
    end
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
            effect = global_mouvement!(f_mouv, sequence_meilleure, k, l, ratio_option, tab_violation, Hprio, obj, pbl, f_rand)
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
            for car in sequence_meilleure
                if car[szcar-1]-car[szcar-2]>pbl
                    println(car)
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
            a =evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)
            println("score : ", a,"\n\n")
        end


        # Reset de nb
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
    end

    # Re evaluation en fin d'exection :
    a,b =evaluation_init(sequence_meilleure,sequence_avant,ratio_option,Hprio)
    println(a)
    if verbose
        println(a)
        println("___________________________________________")
    end
    a =evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)
    
    return a, sequence_meilleure, txt
end



# Fonction qui réalise la VFLS pour la génération de la pop initiale
# @param sol : la solution à partir de laquelle commencer
# @param viol : le tab violation associé
# @param score : le score associé
# @param obj : Le tableau de l'ordre des objectif
# @param inst : une instance tel que definie dans generate.jl
# @param temps_solNonElite : le temps pour l'ensemble des phase de la VFLS
# @param verbose : si la fonction va faire de l'affichage pendant son execution
# @param txtoutput : permet une sortie dans un fichier externe
function VFLS_genetic(sol::Array{Array{Int,1},1}, viol::Array{Array{Int,1},1}, score::Array{Int,1}, obj::Array{Int, 1}, inst::Instance, temps_solNonElite::Float64 = 0.1, verbose::Bool = false, txtoutput::Bool = false)
    sequence_meilleure = deepcopy(sol)
    tab_violation = deepcopy(viol)
    score_init = deepcopy(score)
    sz = size(sequence_meilleure)[1]
    szcar = size(sequence_meilleure[1])[1]
    timeOPT, opt = phases_init(obj)



    # affichage initial :
    if verbose
        println("1) Information sur les données :")
        println("   ---------------------------")
        println("Nombre d'options prioritaires : ", inst.Hprio)
        println("PAINT_BATCH_LIMIT : ", inst.pbl)
        println("Nombre de vehicules : ", sz)
        println("\n\n\n")
    end
    txt = ""
    if txtoutput
        txt = string(txt, "1) Information sur l'instance :\n",
                "   ----------------------------\n",
                "Nombre d'options prioritaires : ", inst.Hprio, "\n",
                "PAINT_BATCH_LIMIT : ", inst.pbl, "\n",
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
        for car in sequence_meilleure
            if (car[szcar-1]-car[szcar-2]+1)>pbl
                println(car)
                println(car[szcar-1]-car[szcar-2]+1)
            end
        end
        println(obj)
        println(timeOPT)
    end
    if txtoutput
        txt = string(txt, "2) Information sur la sequence initiale :\n","   ------------------------------------\n")
        for j in 1:length(score_init)
            txt = string(txt, "Valeur sur l'objectif ", j, " : ", score_init[j], "\n")
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

        while temps_solNonElite*(timeOPT[Phase]/100)>time()-debut
            f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
            k, l = choose_f_rand(sequence_meilleure, inst.ratio, tab_violation, f_rand, Phase, obj, inst.Hprio)

            effect = global_mouvement!(f_mouv, sequence_meilleure, k, l, inst.ratio, tab_violation, inst.Hprio, obj, inst.pbl, f_rand)
            compteurMvt!(f_mouv, nb,nb_effectiv,effect)

            # Gestion de l'affichage de la plus belle bar de chargement que l'on est jamais vu :)
            if verbose
                if (time()-debut)>(n/50)*temps_solNonElite*(timeOPT[Phase]/100)
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
            a =evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)
            println("score : ", a,"\n\n")
        end


        # Reset de nb
        nb = [0, 0, 0, 0]
        nb_effectiv = [0,0,0,0]
    end

    # Re evaluation en fin d'exection :
    score_meilleur =evaluation(sequence_meilleure,tab_violation,ratio_option,Hprio)


    return [sequence_meilleure, tab_violation, [score_meilleur]]
end



# Fonction qui realise une comparaison lexicographique
# @param score_courrant : Le score courant comparer à
# @pram score_meilleur : le meilleur score
# @return ::Bool : true si le courrant est mieux
function estMieux(score_courrant::Array{Int,1}, score_meilleur::Array{Int,1})
    return score_courrant >= score_meilleur # Comparaison lexicographique.
end



# Fonction qui compte le nombre de mouvements réalisés
# @param f_mouv : le type de mouvement
# @param nb : le compteur
# @modify nb : mets à jour nb
function compteurMvt!(f_mouv::Symbol, nb::Array{Int, 1},nb_effectiv::Array{Int, 1},effectiv::Bool)
    if f_mouv==:swap!
        nb[1]+=1
    elseif f_mouv==:insertion!
        nb[2]+=1
    elseif f_mouv==:reflection!
        nb[3]+=1
    else
        nb[4]+=1
    end
    if effectiv
        if f_mouv==:swap!
            nb_effectiv[1]+=1
        elseif f_mouv==:insertion!
            nb_effectiv[2]+=1
        elseif f_mouv==:reflection!
            nb_effectiv[3]+=1
        else
            nb_effectiv[4]+=1
        end
    end
    nothing
end



# Fonction d'evaluation d'une instance
# @param instance : l'instance a evaluer
# @param tab_violation : bon si t'as toujours pas compris ce que c'etait c'est que t'as meme pas lu le sujet
# @param ratio : idem
# @param Hprio : Le nombre de hprio
# @return ::Array{Int,1} : [nombre de couleurs fail, H prio fail,L prio fail]
function evaluation(instance::Array{Array{Int,1},1},tab_violation::Array{Array{Int,1},1},ratio::Array{Array{Int,1},1},Hprio::Int)
    col = instance[1][2]
    sz =size(instance)[1]
    nbcol = 0
    Hpriofail=0
    Lpriofail=0
    maxprio =0

    for n in instance
        if n[2]!= col
            nbcol+=1
            col=n[2]
        end

    end
    for i in 1:sz
        for ii in 1:size(tab_violation)[1]
            if tab_violation[ii][i]>0
                if ii<=Hprio
                    Hpriofail+=tab_violation[ii][i]
                else
                    Lpriofail+=tab_violation[ii][i]
                end

            end
        end
    end
    return [nbcol,Hpriofail,Lpriofail]
end
