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
    # TODO : realiser le crossover
    enfant = crossoverCouleur(papa, maman, population, inst)

    return enfant
end




# Crossover pour améliorer les couleurs (si l'enfant est pas admissible on en refait un)
# @param papa : l'indice du papa dans la population
# @param maman : l'indice de la maman dans la population
# @param population : la population globale
# @param inst : L'instance du problème étudié cf Util/instance.jl
# @return ::Array{Array{Array{Int,1},1},1} : l'enfant générer
function crossoverCouleur(papa::Int, maman::Int, population::Array{Array{Array{Array{Int,1},1},1},1},inst::Instance)
    println("\n")
    println("------------------------CROSSOVER---------------------------", "\n")
    println("taille de la population : ", length(population))
    println("taille maman ; ", length(population[maman][1]))
    println("taille papa ; ", length(population[papa][1]))
    debCol = length(population[papa][1][1])-2
    finCol = length(population[papa][1][1])-1
    id = length(population[papa][1][1])
    nbCars = length(population[papa][1])
    
    #points de coupe du crossover (on coupe sur le pere puis on injecte dans la maman)
    cut1 = rand(1:nbCars)
    cut2 = rand(cut1:nbCars)
    println("cut1Avant : ", cut1)
    println("cut2Avant : ", cut2)
    #on décale les points au debut et à la fin du bloc de couleur 
    cut1 = population[papa][1][cut1][debCol]
    cut2 = population[papa][1][cut2][finCol]
    println("cut1 : ", cut1)
    println("cut2 : ",cut2)
    println("verifier couleurs maman")
    verifierBlocsCol(population[maman][1])
    println("verifier couleurs papa")
    verifierBlocsCol(population[papa][1])
    
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
                            push!(enfant,population[maman][1][remplacerInd[j]])
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
                            push!(enfant,population[maman][1][remplacerInd[j]])
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
                push!(enfant,population[maman][1][remplacerInd[j]])
                deleteat!(remplacerID,j)
                deleteat!(remplacerInd,j)
            end
        else #on copie simplement la voiture de la mère dans le fils
            push!(enfant,population[maman][1][i])
        end
    end
    println("taille enfant jusqu'à cut1-1: ", length(enfant), "\n")
    #println("enfant id jusqu'à cut1-1 : ", [enfant[i][id] for i in 1:(cut1-1)], "\n")
    #de cut1 à cut2 : on copie le père
    for i in cut1:cut2
        push!(enfant,population[papa][1][i])
    end
        println("taille enfant jusqu'à cut2: ", length(enfant), "\n")
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
                            push!(enfant,population[maman][1][remplacerInd[j]])
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
                            push!(enfant,population[maman][1][remplacerInd[j]])
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
                push!(enfant,population[maman][1][remplacerInd[j]])
                deleteat!(remplacerID,j)
                deleteat!(remplacerInd,j)
            end
        else #on copie simplement la voiture de la mère dans le fils
            push!(enfant,population[maman][1][i])
        end
    end
    println("taille enfant : ", length(enfant), "\n")
    #println("enfant id : ", [enfant[i][id] for i in 1:nbCars], "\n")
    verifierVoitures(enfant)
    verifierPapa(enfant,population[papa][1],cut1,cut2)
    
    #on verifie que le crossover est admissible (pbl)
    #et on met à jour les données : tab violation, blocs de couleur
    enfant,violEnfant, pblAdmissible = majData(enfant, inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl)
    #population[papa][2], houit = majData(population[papa][1], inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl)
    #population[maman][2], houit = majData(population[maman][1], inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl)
    
    println("verifier couleurs enfant")
    verifierBlocsCol(enfant)
    #si l'enfant est pas admissible : on refait un crossover
    if !pblAdmissible
        println("PBL non admissible : on refait un crossover")
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
function majData(instance::Array{Array{Int,1},1},sequence_j_avant::Array{Array{Int,1},1},ratio::Array{Array{Int,1},1},Hprio::Int,pbl::Int)
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
                return instance,tab_violation,pblAdmissible
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
    println("\n", "blocsCol : ", blocsCol, "\n")
    for i in 1:(length(blocsCol)-1)
        debBloc = blocsCol[i]
        finBloc = blocsCol[i+1]-1
        for j in debBloc:finBloc
            instance[j][debCol] = debBloc
            instance[j][finCol] = finBloc
        end
    end
    
    println("verification couleurs juste à la fin du majData : ")
    verifierBlocsCol(instance)
    
    #l'instance est pas retournée car on veut juste la modifier (pas de copie memoire tmtc)
    return instance,tab_violation,pblAdmissible
end



#-------------------------------fonctions POUR TESTER que le crossover est ok----------------------------
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
function verifierBlocsCol(instance::Array{Array{Int,1},1})
    debCol = length(instance[1])-2
    finCol = length(instance[1])-1 
    println("couleur,debCol,finCol : ", [(instance[i][2], instance[i][debCol], instance[i][finCol]) for i in 1:length(instance)] )
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
