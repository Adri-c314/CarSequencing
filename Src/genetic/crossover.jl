# Fichier contenant toutes les fonction associées au crossover entre plusieurs sequence
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1



# Fonction qui realise le crossover entre deux sequences
# @param papa : l'indice du papa dans la population
# @param maman : l'indice de la maman dans la population
# @param population : la population globale
# @param obj : l'objectif in (:pbl!, :hprio!, :lprio!) suivant l'obj qu'on focus
# @param inst : L'instance du problème étudié cf Util/instance.jl
# @return ::Array{Array{Array{Int,1},1},1} : l'enfant générer
function crossover(papa::Int, maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1}, obj::Symbol, inst::Instance)
    #Hprio/LPrio/Pbl
    #println("debut crossover")
    if obj == :pbl!
        #println("PblCross")
        enfant = crossoverCouleur(papa, maman, population, inst)
    elseif obj == :hprio!
        #println("HPOCross")
        enfant = crosshprio!(papa, maman, population, inst)
    else
        #println("LPOCross")
        enfant = crosslprio!(papa, maman, population, inst)
    end
    #println("fin crossover")
    #println(typeof(sequence),typeof(tab_violation),typeof(score))
    return enfant
end




# Crossover pour améliorer les couleurs (si l'enfant est pas admissible on en refait un)
# @param papa : l'indice du papa dans la population
# @param maman : l'indice de la maman dans la population
# @param population : la population globale
# @param inst : L'instance du problème étudié cf Util/instance.jl
# @return ::Array{Array{Array{Int,1},1},1} : l'enfant générer
function crossoverCouleur(papa::Int, maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1},inst::Instance,verbose = false)
    if verbose
        println("\n")
        println("------------------------CROSSOVER---------------------------", "\n")
        println("taille de la population : ", length(population))
        println("taille maman ; ", length(population[maman][1]))
        println("taille papa ; ", length(population[papa][1]))
    end
    debCol = length(population[papa][1][1])-2
    finCol = length(population[papa][1][1])-1
    id = length(population[papa][1][1])
    nbCars = length(population[papa][1])

    #on maj les blocs couleurs des parents
    violMaman, pblAdmissible = majData(population[maman][1], inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl,verbose)
    if verbose println("verifier couleurs maman") end
    verifierBlocsCol(population[maman][1],verbose)
    violPapa, pblAdmissible = majData(population[papa][1], inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl,verbose)
    if verbose println("verifier couleurs papa") end
    verifierBlocsCol(population[papa][1],verbose)

    #points de coupe du crossover (on coupe sur le pere puis on injecte dans la maman)
    cut1 = rand(1:nbCars)
    cut2 = rand(cut1:nbCars)
    if verbose
        println("cut1Avant : ", cut1)
        println("cut2Avant : ", cut2)
    end
    #on décale les points au debut et à la fin du bloc de couleur
    cut1 = population[papa][1][cut1][debCol]
    cut2 = population[papa][1][cut2][finCol]
    if verbose
        println("cut1 : ", cut1)
        println("cut2 : ",cut2)
    end

    #on stock les ID des voitures du pere entre cut1 et cut2
    idPere = [population[papa][1][i][id] for i in cut1:cut2]

    #on identifie les voitures de la maman entre les 2 cut qui devront bouger suite au crossover
    remplacerID = Array{Int,1}()
    remplacerInd = Array{Int,1}()

    for car in cut1:cut2
        if !(population[maman][1][car][id] in idPere)
            push!(remplacerID, population[maman][1][car][id])
            push!(remplacerInd, car)
        end
    end

    #println("maman id : ", [population[maman][1][i][id] for i in 1:nbCars], "\n")
    #println("papa id : ", [population[papa][1][i][id] for i in 1:nbCars], "\n")

    #création de la séquence de l'enfant
    enfant = Array{Array{Int,1},1}()

    #de 1 à cut1 : on copie la mère en gérant les doublons possibles
    for i in 1:(cut1 - 1)
        if population[maman][1][i][id] in idPere #doublon
            #95% de chance que le remplacement soit déterminisite; 5% de chance qu'il soit random (comme dans le papier genetic)
            r = rand()
            remplace = false
            if r < 0.95 #on essaye de remplacer par une voiture qui a la même couleur qu'au moins un voisin
                j = 1
                if i == 1 #on regarde la couleur que de la voiture suivante
                    while (j <= length(remplacerInd)) & !remplace
                        if population[maman][1][remplacerInd[j]][2] == population[maman][1][i+1][2]
                            push!(enfant,deepcopy(population[maman][1][remplacerInd[j]]))
                            deleteat!(remplacerID,j)
                            deleteat!(remplacerInd,j)
                            remplace = true
                        else
                            j += 1
                        end
                    end
                else #on regarde la couleur de la voiture suivante et précédente
                    while (j <= length(remplacerInd)) & !remplace
                        if (population[maman][1][remplacerInd[j]][2] == population[maman][1][i+1][2]) ||
                        (population[maman][1][remplacerInd[j]][2] == population[maman][1][i-1][2])
                            push!(enfant,deepcopy(population[maman][1][remplacerInd[j]]))
                            deleteat!(remplacerID,j)
                            deleteat!(remplacerInd,j)
                            remplace = true
                        else
                            j += 1
                        end
                    end
                end
            end
            if (r >= 0.95) | !remplace #remplacement random
                j = rand(1:length(remplacerInd))
                push!(enfant,deepcopy(population[maman][1][remplacerInd[j]]))
                deleteat!(remplacerID,j)
                deleteat!(remplacerInd,j)
            end
        else #on copie simplement la voiture de la mère dans le fils
            push!(enfant,deepcopy(population[maman][1][i]))
        end
    end
    if verbose println("taille enfant jusqu'à cut1-1: ", length(enfant), "\n") end
    #de cut1 à cut2 : on copie le père
    for i in cut1:cut2
        push!(enfant,population[papa][1][i])
    end
        if verbose println("taille enfant jusqu'à cut2: ", length(enfant), "\n") end
        #println("enfant id de jusqu'à cut2 : ", [enfant[i][id] for i in 1:cut2], "\n")
    #de cut2 jusqu'à la fin : on copie la mère en gérant les doublons possibles
    for i in (cut2+1):nbCars
        if population[maman][1][i][id] in idPere #doublon
            #95% de chance que le remplacement soit déterminisite; 5% de chance qu'il soit random (comme dans le papier genetic)
            r = rand()
            remplace = false
            if r < 0.95 #on essaye de remplacer par une voiture qui a la même couleur qu'au moins un voisin
                j = 1
                if i == nbCars #on regarde la couleur que de la voiture précédente
                    while j <= length(remplacerInd) & !remplace
                        if population[maman][1][remplacerInd[j]][2] == population[maman][1][i-1][2]
                            push!(enfant,deepcopy(population[maman][1][remplacerInd[j]]))
                            deleteat!(remplacerID,j)
                            deleteat!(remplacerInd,j)
                            remplace = true
                        else
                            j += 1
                        end
                    end
                else #on regarde la couleur de la voiture suivante et précédente
                    while j <= length(remplacerInd) & !remplace
                        if (population[maman][1][remplacerInd[j]][2] == population[maman][1][i+1][2]) ||
                        (population[maman][1][remplacerInd[j]][2] == population[maman][1][i-1][2])
                            push!(enfant,deepcopy(population[maman][1][remplacerInd[j]]))
                            deleteat!(remplacerID,j)
                            deleteat!(remplacerInd,j)
                            remplace = true
                        else
                            j += 1
                        end
                    end
                end
            end
            if (r >= 0.95) | !remplace #remplacement random
                j = rand(1:length(remplacerInd))
                push!(enfant,deepcopy(population[maman][1][remplacerInd[j]]))
                deleteat!(remplacerID,j)
                deleteat!(remplacerInd,j)
            end
        else #on copie simplement la voiture de la mère dans le fils
            push!(enfant,deepcopy(population[maman][1][i]))
        end
    end
    if verbose println("taille enfant : ", length(enfant), "\n") end
    verifierVoitures(enfant)
    verifierPapa(enfant,population[papa][1],cut1,cut2)

    #on verifie que le crossover est admissible (pbl)
    #et on met à jour les données : tab violation, blocs de couleur
    violEnfant, pblAdmissible = majData(enfant, inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl,verbose)

    if verbose println("verifier couleurs enfant") end
    #verifierBlocsCol(enfant,verbose)
    #si l'enfant est pas admissible : on refait un crossover
    if !pblAdmissible
        if verbose println("PBL non admissible : on refait un crossover") end
        return crossoverCouleur(papa, maman, population,inst)
    else
        return [enfant, violEnfant, [[0,0,0]]]
    end
end




# verifier que le crossover est admissible, et maj tab violation et blocs couleur
# @param instance : l'instance courante
# @param ratio : le tableau de ratio
# @param hprio : Le nombre de prioritaire h
# @param sequence_j_avant : la sequence d'hier
# @param pbl : paint batch limit
# @return tab violation de l'enfant
# @return pblAdmissible : booléen : pour savoir si l'enfant est admissible ou pas
function majData(instance::Array{Array{Int,1},1},sequence_j_avant::Array{Array{Int,1},1},ratio::Array{Array{Int,1},1},Hprio::Int,pbl::Int,verbose=false)
    sz =size(instance)[1]
    sz_avant =size(sequence_j_avant)[1]
    col = sequence_j_avant[sz_avant][2]
    debCol = length(instance[1])-2
    finCol = length(instance[1])-1
    checkPBL = 0
    pblAdmissible = true
    #indices des debut des blocs de couleur
    blocsCol = [1]

    #tab violation
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
        #verifier pbl et stocker indice debut bloc couleur
        if n[2]== col
            checkPBL += 1
            if checkPBL > pbl
                pblAdmissible = false
                return tab_violation,pblAdmissible, instance
            end
        else
            col=n[2]
            checkPBL = 0
            if tmpi > 1
                push!(blocsCol,tmpi)
            end
        end

        #tab violation
        tmprio = 1
        for eval in evalrat
            for i in 1:size(eval)[1]
                #on ajoute 1 si la vouture n a bien la prio
                if n[tmprio+2]==1

                    eval[i]+=1
                end
                #on reset quand on a regarde plus de x voitures avec x => y/x
                if mod(tmpi-i,ratio[tmprio][2])==0
                    tab_violation[tmprio][tmpi]+=eval[i]

                    eval[i]=0
                end
            end
            tmprio+=1
        end
        tmpi+=1
    end


    #maj des blocs de couleur
    push!(blocsCol,sz+1)
    if verbose println("\n", "blocsCol : ", blocsCol, "\n") end
    for i in 1:(length(blocsCol)-1)
        debBloc = deepcopy(blocsCol[i])
        finBloc = deepcopy(blocsCol[i+1]-1)
        for j in debBloc:finBloc
            instance[j][debCol] = debBloc
            instance[j][finCol] = finBloc
        end
    end

    if verbose println("verification couleurs juste à la fin du majData : ") end
    verifierBlocsCol(instance)
    #println(instance)
    #l'instance est pas retournée car on veut juste la modifier (pas de copie memoire tmtc)
    return tab_violation,pblAdmissible,instance
end



#-------------------------------fonctions POUR TESTER que le crossover couleur est ok----------------------------
#verifier que toutes les voitures de la sequence sont différentes
function verifierVoitures(enfant::Array{Array{Int,1},1})
    id = length(enfant[1])
    idEnfant = []
    for car in enfant
        if car[id] in idEnfant
            error("!!!!!popopo y'a une voiture qui apparait 2 fois laaaa !!!!!")
        end
        push!(idEnfant, car[id])
    end
end

#verifier qu'on a bien le pere entre cut1 et cut2
function verifierPapa(enfant::Array{Array{Int,1},1}, papa::Array{Array{Int,1},1}, cut1::Int64, cut2::Int64)
    id = length(enfant[1])
    for car in cut1:cut2
        if enfant[car][id] != papa[car][id]
            error("!!!!!Le pauvre papa il est pas copié bah c'est pas trop un crossover ca!!!!!!")
        end
    end
end

#verifier que les debuts/fins de blocs de couleur correspondent bien
function verifierBlocsCol(instance::Array{Array{Int,1},1},verbose = false)
    debCol = length(instance[1])-2
    finCol = length(instance[1])-1
    if verbose println("couleur,debCol,finCol : ", [(instance[i][2], instance[i][debCol], instance[i][finCol]) for i in 1:length(instance)] ) end
    i = 1
    while i <= length(instance)
        col = instance[i][2]
        debBloc = instance[i][debCol]
        finBloc = instance[i][finCol]
        while i <= finBloc
            if (instance[i][2] != col) | (instance[i][debCol] != debBloc) | (instance[i][finCol] != finBloc)
                error("euh ya un pb au niveau des blocs de couleur la : indice ", i)
            end
            i += 1
        end
    end
end


#Fonction qui calcul la meilleure voiture à inserer
#@param other : voitures disponibles
#@param E1 : séquence en cours de construction
#@param maman : séquence de la maman
#@param pos : position où l'on doit insérer
#@param choixPrio :  1:HPO ou 2:LPO
#@return car : position de la voiture à ajouter
function selectBest!(other::Array{Int64,1}, E1::Array{Array{Int,1},1}, maman::Array{Array{Int,1},1}, pos::Int, ratio_option::Array{Array{Int,1}}, Hprio::Int, choixPrio::Int)
    current = 1
    if choixPrio==1
        InterestMin=interestHpo!(other[current],E1,maman,pos,ratio_option,Hprio)
    else
        InterestMin=interestLpo!(other[current],E1,maman,pos,ratio_option,Hprio)
    end

    car = other[current]
    index = current
    while current < size(other)[1] && InterestMin != 0
        current+=1
        if choixPrio==1
            currentInterest=interestHpo!(other[current],E1,maman,pos,ratio_option,Hprio)
        else
            currentInterest=interestLpo!(other[current],E1,maman,pos,ratio_option,Hprio)
        end
        if currentInterest < InterestMin
            InterestMin = currentInterest
            car = other[current]
            index = current
        end
    end
    return car,index
end

#Fonction qui l'interet de la voiture à inserer
#@param car : voiture qu'on cherche à inserer
#@param E : séquence enfant en cours de construction
#@param maman : séquence de la maman
#@param pos : position où l'on doit insérer
#@param ratio : ratio d'options
#@param Hprio nombre d'options à traiter
#@return conflit : le nb de conflits créés
function interestHpo!(car::Int, E::Array{Array{Int,1},1}, maman::Array{Array{Int,1},1}, pos::Int,ratio::Array{Array{Int,1}}, HPrio::Int)
    conflit = 0
    for i in 1:HPrio
        nbOption = 0
        for j in max(pos-ratio[i][2]+1,1):pos
            if E[j][i+2] != 0
                nbOption+=1
            end
        end
        nbOption+=maman[car][i+2]
        if nbOption > ratio[i][2] - ratio[i][1]
            conflit+=1
        end
    end
    return conflit
end

#Fonction qui l'interet de la voiture à inserer
#@param car : voiture qu'on cherche à inserer
#@param E : séquence enfant en cours de construction
#@param maman : séquence de la maman
#@param pos : position où l'on doit insérer
#@param ratio : ratio d'options
#@param Lprio nombre d'options à traiter
#@return conflit : le nb de conflits créés
function interestLpo!(car::Int, E::Array{Array{Int,1},1}, maman::Array{Array{Int,1},1}, pos::Int,ratio::Array{Array{Int,1}}, HPrio::Int)
    conflit = 0
    for i in HPrio+1:size(ratio)[1]
        nbOption = 0
        for j in max(pos-ratio[i][2]+1,1):pos
            if E[j][i+2] != 0
                nbOption+=1
            end
        end
        nbOption+=maman[car][i+2]
        if nbOption > ratio[i][2] - ratio[i][1]
            conflit+=1
        end
    end
    return conflit
end

# Fonction qui realise le crossover entre deux sequences
# @param papa : l'indice du papa dans la population
# @param maman : l'indice de la maman dans la population
# @param population : la population globale
# @param obj : l'objectif in (:pbl!, :hprio!, :lprio!) suivant l'obj qu'on focus
# @param inst : L'instance du problème étudié cf Util/instance.jl
# @return ::Array{Array{Array{Int,1},1},1} : l'enfant générer
function HprioEnfant!(maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1}, inst::Instance)
    tab_violation=population[maman][2]
    Hprio = inst.Hprio
    ratio = inst.ratio
    sequence_maman = deepcopy(population[maman][1])
    sz = size(sequence_maman)[1]
    szcar =size(sequence_maman[1])[1]
    #println("sz", sz)

    tab_violation, pblAdmissible = majData(population[maman][1], inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl)
    #println("verifier couleurs maman")
    verifierBlocsCol(population[maman][1])

    #crossover sur P1 : maman
    nbPosHpo = 0
    #tabconflictHpo = Array{Int,1}(undef,sz)
    tabconflictHpo=map(x->0, tab_violation[1])
    for i in 1:Hprio
        for j in 1:sz
            tabconflictHpo[j] = max(tab_violation[i][j],tabconflictHpo[j],0)
        end
    end
    PosHpoConflict = findall(x->x>0, tabconflictHpo)
    PosHpo = findall(x->x<=0, tabconflictHpo)
    if size(PosHpo)[1]==0
        #println(PosHpo)
        #println(PosHpoConflict)
        #println(tab_violation)
        #println(tabconflictHpo)
        println("Mauvaise gestion des conflits -> debbug crossover Prio")
    end
    nbPosHpo = size(PosHpo)[1]
    randHpo = rand(0:nbPosHpo)
    randPosHpo = rand(1:nbPosHpo)
    debut=randPosHpo

    #println("tab voitures sans conflit",PosHpo)
    #println("tab voitures avec conflit",PosHpoConflict)

    #Step 1 On ajoute un nb de voitures sans conflits
    #E1 = deepcopy(sequence_maman)
    #elementNul=map(x->0, deepcopy(sequence_maman[1]))
    #E1 = map(x -> elementNul, deepcopy(sequence_maman))
    elementNul=zeros(Int, length(sequence_maman[1]))
    E1 = Array{Array{Int,1},1}()
    for i in 1:length(sequence_maman)
        push!(E1, elementNul)
    end

    ajout = 0
    while ajout < randHpo
        E1[PosHpo[randPosHpo]]=deepcopy(sequence_maman[PosHpo[randPosHpo]])
        randPosHpo+=1
        if randPosHpo > nbPosHpo
            randPosHpo=1
        end
        ajout+=1
    end

    if debut+randHpo>size(PosHpo)[1]
        #deb = randPosHpo + randHpo - size(PosHpo)[1]
        other = vcat(PosHpo[randPosHpo:debut-1],PosHpoConflict)
    else
        other = vcat(PosHpo[1:debut-1],PosHpo[randPosHpo:size(PosHpo)[1]])
        other = vcat(other,PosHpoConflict)
    end
    #println("other",other)
    randOther = rand(1:sz)
    nbcar=size(other)[1]

    #Step2 On ajoute les voitures restantes
    while E1[randOther]!=elementNul && size(other)[1]!=0
        randOther+=1
        if randOther>sz
            randOther=1
        end
    end

    for j in 1:nbcar
        voiture, indexVoiture= selectBest!(other,E1,sequence_maman,randOther,ratio,Hprio,1)
        #println("index",indexVoiture, " voiture ", voiture, "randother",randOther)

        E1[randOther]=sequence_maman[voiture]
        fin =size(other)[1]
        if indexVoiture != 1 && indexVoiture != fin
            other=vcat(other[1:indexVoiture-1], other[indexVoiture+1:fin])
        elseif indexVoiture == 1
            other=other[2:fin]
        else
            other=other[1:fin-1]
        end
        randOther+=1
        if randOther>sz
            randOther=1
        end
        while E1[randOther]!=elementNul && size(other)[1]!=0
            randOther+=1
            if randOther>sz
                randOther=1
            end
        end
    end
    #println("Enfant fin",E1)

    #test sequence valide
    for i in 1:sz
        positionnn=findfirst(x -> x==sequence_maman[i],E1)[1]
    end

    ##Evaluation
    tab_violationE1, checkPbl, E1 = majData(E1,sequence_maman,ratio,Hprio,inst.pbl)
    #println(E1)
    #println("verification couleurs juste à la fin du majData : ")
    #verifierVoitures(E1)
#    verifierBlocsCol(E1)
    if !checkPbl
        #println("PBL non admissible : on refait un crossover")
        return HprioEnfant!(maman, population,inst)
    else
        #println(E1)
        return [E1, tab_violationE1, [[0,0,0]]]
    end
end

function LprioEnfant!(maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1}, inst::Instance)
    tab_violation=population[maman][2]
    Hprio = inst.Hprio
    ratio = inst.ratio
    sequence_maman = deepcopy(population[maman][1])
    sz = size(sequence_maman)[1]
    szcar =size(sequence_maman[1])[1]
    #println("sz", sz)
    tab_violation, pblAdmissible = majData(population[maman][1], inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl)
    #println("verifier couleurs maman")
    #verifierBlocsCol(population[maman][1])

    #crossover sur P1 : maman
    nbPosHpo = 0
    #tabconflictHpo =Array{Int,1}(undef,sz)
    tabconflictHpo=map(x->0, tab_violation[1])
    for i in Hprio+1:size(ratio)[1]
        for j in 1:sz
            tabconflictHpo[j] = max(tab_violation[i][j],tabconflictHpo[j],0)
        end
    end
    PosHpoConflict = findall(x->x>0, tabconflictHpo)
    PosHpo = findall(x->x<=0, tabconflictHpo)
    if size(PosHpo)[1]==0
        #println(PosHpo)
        #println(PosHpoConflict)
        #println(tab_violation)
        #println(tabconflictHpo)
        println("Mauvaise gestion des conflits -> debbug crossover Prio")
    end
    nbPosHpo = size(PosHpo)[1]
    randHpo = rand(0:nbPosHpo)
    randPosHpo = rand(1:nbPosHpo)
    debut=randPosHpo

    #println("tab voitures sans conflit",PosHpo)
    #println("tab voitures avec conflit",PosHpoConflict)

    #Step 1 On ajoute un nb de voitures sans conflits
    #E1 = sequence_maman

    elementNul=zeros(Int, length(sequence_maman[1]))
    E1 = Array{Array{Int,1},1}()
    for i in 1:length(sequence_maman)
        push!(E1, elementNul)
    end

    ajout = 0
    while ajout < randHpo
        E1[PosHpo[randPosHpo]]=sequence_maman[PosHpo[randPosHpo]]
        randPosHpo+=1
        if randPosHpo > nbPosHpo
            randPosHpo=1
        end
        ajout+=1
    end

    if debut+randHpo>size(PosHpo)[1]
        #deb = randPosHpo + randHpo - size(PosHpo)[1]
        other = vcat(PosHpo[randPosHpo:debut-1],PosHpoConflict)
    else
        other = vcat(PosHpo[1:debut-1],PosHpo[randPosHpo:size(PosHpo)[1]])
        other = vcat(other,PosHpoConflict)
    end
    #println("other",other)
    randOther = rand(1:sz)
    nbcar=size(other)[1]

    #Step2 On ajoute les voitures restantes
    while E1[randOther]!=elementNul && size(other)[1]!=0
        randOther+=1
        if randOther>sz
            randOther=1
        end
    end

    for j in 1:nbcar
        voiture, indexVoiture= selectBest!(other,E1,sequence_maman,randOther,ratio,Hprio,2)
        #println("index",indexVoiture, " voiture ", voiture, "randother",randOther)

        E1[randOther]=deepcopy(sequence_maman[voiture])
        fin =size(other)[1]
        if indexVoiture != 1 && indexVoiture != fin
            other=vcat(other[1:indexVoiture-1], other[indexVoiture+1:fin])
        elseif indexVoiture == 1
            other=other[2:fin]
        else
            other=other[1:fin-1]
        end
        randOther+=1
        if randOther>sz
            randOther=1
        end
        while E1[randOther]!=elementNul && size(other)[1]!=0
            randOther+=1
            if randOther>sz
                randOther=1
            end
        end
    end
    #println("Enfant fin",E1)

    #test sequence valide
    for i in 1:sz
        positionnn=findfirst(x -> x==sequence_maman[i],E1)[1]
    end
    ##Evaluation
    tab_violationE1, checkPbl = majData(E1,sequence_maman,ratio,Hprio,inst.pbl)
    #println("verification couleurs juste à la fin du majData : ")
    #verifierVoitures(E1)
    #verifierBlocsCol(E1)
    if !checkPbl
        #println("PBL non admissible : on refait un crossover")
        return LprioEnfant!(maman, population,inst)
    else
        #println(E1)
        return [E1, tab_violationE1, [[0,0,0]]]
    end
end

function crosshprio!(papa::Int, maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1}, inst::Instance)
    #println("HprioCross")
    enfant1 = HprioEnfant!(maman, population, inst)
    enfant2 = HprioEnfant!(papa, population, inst)
    if rand(1:2) == 1
        #println("Score enfant : ",score2)
        return enfant2
    else
        #println("Score enfant : ",score1)
        return enfant1
    end
end

function crosslprio!(papa::Int, maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1}, inst::Instance)
    #println("LprioCross")
    enfant1=LprioEnfant!(maman, population, inst)
    enfant2=LprioEnfant!(papa, population, inst)
    if rand(1:2) == 1
        #println("Score enfant : ",score2)
        return enfant2
    else
        #println("Score enfant : ",score1)
        return enfant1
    end
end
