# Fichier contenant toutes les fonctions associées à l'algorithm génétique dans sa gloablité
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1



# Fonction qui réalise l'ensemble de l'algorithm génétique
# @param datas : Le jeux de données lu
# @param nbSol : la taille de la population
# @param temps_init : le temps alloué a la création de la solution initiale commune
# @param temps_phase1 : Le temps alloué à la premiere phase d'amélioration pour les solutions elites
# @param temps_phaseAutres : Le temps alloué aux autres phases d'amélioration pour les solutions elites
# @param temps_popNonElite : Le temps alloué à tout le processus d'amélioration pour les solutions non élites
# @param temps_global : Le temps alloué à tout l'algo genetique apres generation de la population de depart
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
function genetic(datas::NTuple{4,DataFrame}, nbSol::Int, temps_init::Float64 = 120., temps_phase1::Float64 = 300., temps_phaseAutres::Float64 = 300., temps_popNonElite::Float64 = 30., temps_global::Float64 = 300., verbose::Bool=true, txtoutput::Bool=true)
    if verbose
        n=0
        st_output = string("Execution : [")
    end

    # Génération de la population de depart
    population = generate(datas, nbSol, temps_init, temps_phase1, temps_phaseAutres, temps_popNonElite, verbose, txtoutput)

    if verbose
        println("2) Réalisation de l'algorithme génétique :")
        println("   ----------------------------------")
        println("Budjet de temps de calcule : ", temps_global, " secondes")
    end

    debut = time()
    while temps_global >= (time()-debut)
        if verbose
            if (time()-debut)>(n/50)*temps_global
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

        # selection prendre des elements de la pop
        #papa, maman = selection(population)
        papa = 1
        maman = 2

        # crossover
        enfant = crossover(papa, maman, population, focus)

        # mutation
        #mutation!(enfant)

        # insertion dans la pop ?
        #insertionPotentielle!(population, enfant)
    end
end
