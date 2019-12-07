# Fichier toutes les fonction associé à la PLS
# @author Xavier Pillet
# @author Thaddeus Leonard
# @author Corentin Pelhatre
# @date 05/12/2019
# @version 1



# Theoriquement fonctionnel mais aura peut-etre besoin d'une phase de debbug.
# Necessite une population de base pour commencer (par exemple celle du genetique).



# Fonction qui réalise la Pareto Local Search
# @param NDtree : l'abre tel que défini dans Sommet.jl
# @param inst : L'instance du problème tel que defini dans instance.jl
# @param temps_max : Le temps pour toute la PLS
# @param temps_1_moov : Le temps associé à un unique mouvement (proportion de temps_max)
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
function PLS!(NDtree::Sommet, inst::Instance, temps_max::Float64 = 1.0, temps_1_moove::Float64 = temps_max/1000., verbose::Bool = true, txtoutput::Bool=true)
    # Gestion d'un affichage :
    if verbose
        println("   ------------------------------------")
        println("   Lancement de la Pareto Local Search pour : ", temps_max, " s")
    end
    txt = ""
    if txtoutput
        txt = string(txt, "   ------------------------------------\n", "   Lancement de la Pareto Local Search pour : ", temps_max, " s\n")
    end

    pareto_tmp = get_solutions(NDtree)

    compteur_solutions_trouvees = 0
    compteur_solutions_trouvees_efficasses = 0
    nb = 0
    nb_effective = 0

    # La barre de chargement qui fait du bien
    if verbose
        n=0
        st_output = string("Execution : [")
    end
    debut = time()
    while temps_max > time() - debut
        # La barre de chargement qui fait du bien
        if verbose
            if (time()-debut)>(n/50)*temps_max
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

        local pareto = deepcopy(pareto_tmp)
        for y in pareto_tmp
            local y_tmp = LS(y)
            while !maj!(NDtree, y_tmp)
                recherche_locale!(ytmp, inst, nb, nb_effective, temps_1_moov)
                compteur_solutions_trouvees += 1
            end
            append!(pareto_tmp, [deepcopy(y_tmp)])
            compteur_solutions_trouvees_efficasses += 1
        end
    end

    # Gestion d'un affichage :
    if verbose
        println("   ------------------------------------")
        println("   Fin de la Pareto Local Search")
        println("Nombre de swap : ",nb[1],", Nombre de swap_effectif : ",nb_effectiv[1])
        println("Nombre d'insertion : ",nb[2],", Nombre de insertion_effectif : ",nb_effectiv[2])
        println("Nombre de reflection : ",nb[3],", Nombre de reflection_effectif : ",nb_effectiv[3])
        println("Nombre de shuffle : ",nb[4],", Nombre de shuffle_effectif : ",nb_effectiv[4])
        println("Nombre de solutions trouvees : ", compteur_solutions_trouvees, "Nombre de solutions trouvees : ", compteur_solutions_trouvees_efficasses)
    end
    if txtoutput
        txt = string(txt, "   ------------------------------------\n", "   Fin de la Pareto Local Search\n", "Nombre de swap : ",nb[1],", Nombre de swap_effectif : ",nb_effectiv[1], "\nNombre d'insertion : ",nb[2],", Nombre de insertion_effectif : ",nb_effectiv[2], "\nNombre de reflection : ",nb[3],", Nombre de reflection_effectif : ",nb_effectiv[3], "\nNombre de shuffle : ",nb[4],", Nombre de shuffle_effectif : ", nb_effectiv[4], "\nNombre de solutions trouvees : ", compteur_solutions_trouvees, "Nombre de solutions trouvees : ", compteur_solutions_trouvees_efficasses)
    end

    # Pour le txtoutput
    return txt
end



# Fonction qui converti du genetic vers le pls
# @param y : un membre de la population du génétic
# @return ::Tuple{Array{U,1}, Array{T,1}, Q} : Utile pour la PLS
function convert_genetic_PLS(y::Array{T,1}) where T
    return (y[1], y[3], y[2])
end



# Fonction qui réalise une VFLS legerement custom pour PLS
# @param y : L'instance tel que def dans PLS
# @param inst : L'instance du problème tel que defini dans instance.jl
# @param nb : le compteur de mouvements
# @param nb_effectiv : Le compteur de mouvements effectifs
# @param temps_1_moove : Le temps associé à cette VFLS custom
# @modify y : On lui applique la VFLS
function recherche_locale!(y::Tuple{Array{U,1}, Array{T,1}, Q}, inst::Instance, nb::Int, nb_effective::Int, temps_1_moove::Float64)  where T <: Real where U where Q
    Phase = rand(1:3)
    obj = [rand(1:3) for i in 1:3]
    timeOPT, opt = phases_init(obj)
    while temps_1_moove*(timeOPT[Phase]/100)>time()-debut
        f_rand, f_mouv = choisir_klLS(y_tmp[3], opt, obj, Phase)
        k, l = choose_f_rand(y_tmp[3], inst.ratio, y_tmp[4], f_rand, Phase, obj, inst.Hprio)
        effect = global_mouvement!(f_mouv, y_tmp[3], k, l, inst.ratio,  y_tmp[4], inst.Hprio, obj, inst.pbl, f_rand)
        compteurMvt!(f_mouv, nb,nb_effectiv,effect)
    end
end
