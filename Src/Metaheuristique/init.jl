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
# @return ::Array{Array{Int32,1},1} : la sequence apres toute l'initialisation
# @return ::Array{Int32,1} : Le score courant
# @return ::Array{Array{Int32,1},1} : tab violation
function compute_initial_sequence(datas)
    sequence::Array{Array{Int32,1},1},prio::Array{Array{Int32,1},1},pbl::Int32,obj::Array{Int32,1},Hprio::Int32 = init_sequence(datas)
    obj[1]==1 ? sequence_courrante = GreedyRAF(sequence,prio,pbl,Hprio) : sequence_courrante = GreedyEP(sequence,prio,pbl,Hprio)
    score_courrant::Array{Int32,1},tab_violation::Array{Array{Int32,1},1} = evaluation_init(sequence_courrante,prio,Hprio) #Score = tableaux des scores des 3 objectifs respectifs.
    sequence_meilleure = deepcopy(sequence_courrante)
    score_meilleur = deepcopy(score_courrant)
    return sequence_meilleure, score_meilleur, tab_violation
end



# Fonction d'initialisation de la premiere sequence à partir des données d'entrée
# @param datas : les données lues sur directement dans le fichier d'input
# @return sequence : La premiere sequence initialisée
# @return rat : le tableau de ratio
# @return pbl : paint_batch_limi
# @return obj : Le tableau d'objectifs
# @return Hprio : Le nombre de prioritaire h
function init_sequence(datas)
    # Initialisation des données :
    vehicles = datas[1]
    oo = datas[2] #optimization_objectives
    pbl = datas[3] #paint_batch_limi
    ratio = datas[4]

    # Creation d'une sequence de base
    sequence = [Int32[]]

    # Ajout de tous les vehicules dans la sequence :
    for i in 1:size(vehicles)[1]
        tmp = Int32[0]
        for ii in 1:(size(vehicles)[2]-3)
            append!(tmp,vehicles[i,ii+3])
        end
        append!(tmp,[0,0,i])
        append!(sequence,[tmp])
    end
    popfirst!(sequence)

    # Mise en forme des ratios :
    rat = [Int32[]]
    for i in 1:size(ratio)[1]
        append!(rat,[Int32[0,0]])
        if i ==1
            popfirst!(rat)
        end
        tmp = ratio.Ratio[i]
        tmp = split(tmp,"/")
        rat[i][1]= parse(Int32,tmp[1])
        rat[i][2]= parse(Int32,tmp[2])
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
        if oo[i,2] == "high_priority_level_and_easy_to_satisfy_ratio_constraints"
            obj[i]=2
        elseif oo[i,2] == "paint_color_batches"
            obj[i]=1
        elseif oo[i,2] == "low_priority_level_ratio_constraints"
            obj[i]=3
        end
    end

    return sequence, rat, pbl, obj, Hprio
end



# Fonction d'initialisation de l'evaluation
# @param instance : l'instance courante
# @param ratio : le tableau de ratio
# @param hprio : Le nombre de prioritaire h
# @return [nbcol,Hpriofail,Lpriofail] : l'array des 3 fonctions objectifs
# @return prio : l'array des violations des contraintes avec prio[i][j] le nombre
#         de fois ou l'option j est rencontrée dans la fenetre finissant a i
#         voir p937 proposition 1
function evaluation_init(instance::Array{Array{Int32,1},1},ratio::Array{Array{Int32,1},1},Hprio::Int)
    col = instance[1][2]
    nbcol = 0
    Hpriofail=0
    Lpriofail=0
    ra = Int[]

    for rat in ratio
        append!(ra,[-rat[1]])
    end

    prio = [copy(ra)]

    for i in 1:(size(instance)[1]-1)
        append!(prio,[copy(ra)])
    end

    evalrat = [zeros(Int, ratio[1][2])]
    nbrat = zeros(Int,size(ratio)[1])

    for i in 2:size(ratio)[1]
        append!(evalrat,[zeros(Int, ratio[i][2])])
    end

    tmpi=1

    for n in instance
        tmprio = 1
        for eval in evalrat
            for i in 1:size(eval)[1]
                #on ajoute 1 si la vouture n a bien la prio
                if n[tmprio+2]==1
                    eval[i]+=1
                end
                #on reset quand on a regarde plus de x voitures avec x => y/x
                if mod(tmpi-i,ratio[tmprio][2])==0
                    prio[tmpi][tmprio]+=eval[i]
                    if eval[i]>ratio[tmprio][1]
                        if tmprio>Hprio
                            Lpriofail+=eval[i]-ratio[tmprio][1]
                        else
                            Hpriofail+=eval[i]-ratio[tmprio][1]
                        end
                    end
                    eval[i]=0
                end
            end
            tmprio+=1
        end
        if n[2]!= col
            nbcol+=1
            col=n[2]
        end
        tmpi+=1
    end

    return [nbcol,Hpriofail,Lpriofail], prio
end



# Fonction qui initialise les differentes phases et le temps accordé à chacune
# @return ::Array{Int32,1} : timeOPT
# @return ::Array{Int32,1} : OPT
function phases_init()
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
            OPT[3,3,0]
        else
            timeOPT= [100,0,0]
            OPT = [3,0,0]
        end
    end
    return timeOPT, OPT
end
