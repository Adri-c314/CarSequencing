# Fichier contenant toutes les fonctions d'initialisation de données.
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 1



# Fonction de réalisation de l'operation initial de l'algorithm VFLS
# @param Datas : Tableau de DataFrame bien degueu qu'on s'empresse de nettoyer
# @return ::Array{Array{Int,1},1} : la sequence apres toute l'initialisation
# @return ::Array{Int,1} : Le score courant
# @return ::Array{Array{Int,1},1} : tab violation
# @return ::Array{Array{Int,1},1} : ratio_option le tableau des options
# @return ::Int : Hprio le nombre d'options prioritaires
# @return ::Array{Int,1} : le tableau des objectifs
# @return ::Int : PAINT_BATCH_LIMIT
function compute_initial_sequence(datas::NTuple{4,DataFrame})
    sequence::Array{Array{Int,1},1},prio::Array{Array{Int,1},1},pbl::Int,obj::Array{Int,1},Hprio::Int, sequence_j_avant::Array{Array{Int,1},1} = init_sequence(datas)
    obj[1]==1 ? sequence_courrante = GreedyRAF(sequence,prio,pbl,Hprio) : sequence_courrante = GreedyEP(sequence,prio,pbl,Hprio)
    score_courrant::Array{Int,1},tab_violation::Array{Array{Int,1},1} = evaluation_init(sequence_courrante,sequence_j_avant,prio,Hprio) #Score = tableaux des scores des 3 objectifs respectifs.
    sequence_meilleure = deepcopy(sequence_courrante)
    score_meilleur = deepcopy(score_courrant)
    return sequence_meilleure, score_meilleur, tab_violation, prio, Hprio, obj, pbl
end



# Fonction d'initialisation de la premiere sequence à partir des données d'entrée
# @param datas : les données lues sur directement dans le fichier d'input
# @return sequence : La premiere sequence initialisée
# @return rat : le tableau de ratio
# @return pbl : paint_batch_limi
# @return obj : Le tableau d'objectifs
# @return Hprio : Le nombre de prioritaire h
function init_sequence(datas::NTuple{4,DataFrame})
    # Initialisation des données :
    vehicles = datas[1]
    oo = datas[2] #optimization_objectives
    pbl = datas[3] #paint_batch_limi
    ratio = datas[4]
    # Creation d'une sequence de base
    sequence = [Int[]]
    sequence_j_avant =  [Int[]]
    # Ajout de tous les vehicules dans la sequence :
    j_avant =vehicles[1,1]
    sz_vehicles=0
    for name in names(vehicles)[1:end]
        tmp =split(string(name),"")
        if tmp[1:4] !=["C", "o", "l", "u"]
            sz_vehicles+=1
        end
    end

    for i in 1:size(vehicles)[1]
        if vehicles[i,1] == j_avant
            tmp = Int[0]
            for ii in 1:sz_vehicles-3
                    append!(tmp,vehicles[i,ii+3])
            end
            append!(tmp,[0,0,i])
            append!(sequence_j_avant,[tmp])
        else
            tmp = Int[0]
            for ii in 1:sz_vehicles-3
                    append!(tmp,vehicles[i,ii+3])
            end
            append!(tmp,[0,0,i])
            append!(sequence,[tmp])
        end
    end

    popfirst!(sequence_j_avant)
    popfirst!(sequence)

    # Mise en forme des ratios :
    rat = [Int[]]
    for i in 1:size(ratio)[1]
        append!(rat,[Int[0,0]])
        if i ==1
            popfirst!(rat)
        end
        tmp = ratio.Ratio[i]
        tmp = split(tmp,"/")
        rat[i][1]= parse(Int,tmp[1])
        rat[i][2]= parse(Int,tmp[2])
    end

    # Gestion des Hprio
    Hprio = 0
    for name in names(vehicles)[5:end]
        tmp =split(string(name),"")
        if tmp[1]=="H"
            Hprio+=1
        end
    end

    # Nettoyage pbl
    pbl = pbl.limitation[1]

    # Nettoyage obj
    obj= zeros(3)
    for i in 1:size(oo)[1]
        if oo[i,2] == "high_priority_level_and_difficult_to_satisfy_ratio_constraints" || oo[i,2] =="high_priority_level_and_easy_to_satisfy_ratio_constraints"
            obj[i]=2
        elseif oo[i,2] == "paint_color_batches"
            obj[i]=1
        elseif oo[i,2] == "low_priority_level_ratio_constraints"
            obj[i]=3
        end
    end

    return sequence, rat, pbl, obj, Hprio, sequence_j_avant
end



# Fonction d'initialisation de l'evaluation
# @param instance : l'instance courante
# @param ratio : le tableau de ratio
# @param hprio : Le nombre de prioritaire h
# @return [nbcol,Hpriofail,Lpriofail] : l'array des 3 fonctions objectifs
# @return prio : l'array des violations des contraintes avec prio[i][j] le nombre
#         de fois ou l'option j est rencontrée dans la fenetre finissant a i
#         voir p937 proposition 1
function evaluation_init(instance::Array{Array{Int,1},1},sequence_j_avant::Array{Array{Int,1},1},ratio::Array{Array{Int,1},1},Hprio::Int)
    col = instance[1][2]
    sz =size(instance)[1]
    sz_avant =size(sequence_j_avant)[1]
    nbcol = 0
    Hpriofail=0
    Lpriofail=0
    maxprio =0

    ra = [[-ratio[i][1] for j in 1:size(instance)[1]] for i in 1:size(ratio)[1]]
    tab_violation = ra
    evalrat = [zeros(ratio[i][2]) for i in 1:size(ratio)[1]]
    tmpi=1
    for n in sequence_j_avant
        tmprio = 1
        for eval in evalrat
            for i in 1:size(eval)[1]
                #on ajoute 1 si la vouture n a bien la prio
                if tmpi-i+ratio[tmprio][2]>sz_avant
                    if n[tmprio+2]==1
                        eval[i]+=1
                    end
                end
            end
            tmprio+=1
        end
        tmpi+=1
    end
    tmpi=1
    for n in instance
        tmprio = 1
        if n[2]!= col
            nbcol+=1
            col=n[2]
        end
        for eval in evalrat
            for i in 1:size(eval)[1]
                #on ajoute 1 si la vouture n a bien la prio
                if n[tmprio+2]==1
                    eval[i]+=1
                end
                #on reset quand on a regarde plus de x voitures avec x => y/x
                if tmpi>=ratio[tmprio][2] && mod(tmpi-i,ratio[tmprio][2])==0
                    tab_violation[tmprio][tmpi]+=eval[i]
                    if eval[i]>ratio[tmprio][1]
                        if tmprio>Hprio
                            Lpriofail+=eval[i]-ratio[tmprio][1]
                        else
                            Hpriofail+=eval[i]-ratio[tmprio][1]
                        end
                    end
                end
                if mod(tmpi-i,ratio[tmprio][2])==0
                    eval[i]=0
                end
            end
            tmprio+=1
        end
        tmpi+=1
    end
    return [nbcol,Hpriofail,Lpriofail], tab_violation
end



# Fonction qui initialise les differentes phases et le temps accordé à chacune
# @return ::Array{Int,1} : timeOPT
# @return ::Array{Int,1} : OPT
function phases_init(obj::Array{Int,1})
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
            OPT= [3,3,0]
        else
            timeOPT= [100,0,0]
            OPT = [3,0,0]
        end
    end
    return timeOPT, OPT
end
