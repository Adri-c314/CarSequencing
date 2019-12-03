# Theoriquement fonctionnel mais aura peut-etre besoin d'une phase de debbug.
# Necessite une population de base pour commencer (par exemple celle du genetique).

# Pareto Local Search
function PLS!(NDtree::Sommet, inst::Instance, temps_max::Float64 = 1.0, temps_1_moove::Float64 = temps_max/1000., verbose::Bool = true)
    println("   ------------------------------------")
    println("   Lancement de la Pareto Local Search pour : ", temps_max, " s")
    debut = time()
    pareto_tmp = get_solutions(NDtree)
    compteur_solutions_trouvees = 0
    compteur_solutions_trouvees_efficasses = 0
    nb = 0
    nb_effective = 0
    while temps_max > time() - debut
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
    if verbose
        println("   ------------------------------------")
        println("   Fin de la Pareto Local Search")
        println("Nombre de swap : ",nb[1],", Nombre de swap_effectif : ",nb_effectiv[1])
        println("Nombre d'insertion : ",nb[2],", Nombre de insertion_effectif : ",nb_effectiv[2])
        println("Nombre de reflection : ",nb[3],", Nombre de reflection_effectif : ",nb_effectiv[3])
        println("Nombre de shuffle : ",nb[4],", Nombre de shuffle_effectif : ",nb_effectiv[4])
        println("Nombre de solutions trouvees : ", compteur_solutions_trouvees, "Nombre de solutions trouvees : ", compteur_solutions_trouvees_efficasses)
    end
end

function recherche_locale!(y::Tuple{Array{U,1}, Array{T,1}, Q}, inst::Instance, nb::Int, nb_effective::Int, temps_1_moove::Float64)  where T <: Real where U where Q
    Phase = rand(1:3)
    obj = [rand(1:3) for i in 1:3]
    timeOPT, opt = phases_init(obj)
    while temps_1_moove*(timeOPT[Phase]/100)>time()-debut
        f_rand, f_mouv = choisir_klLS(y_tmp[3], opt, obj, Phase)
        k, l = choose_f_rand(y_tmp[3], inst.ratio, y_tmp[4], f_rand, Phase, obj, inst.Hprio)
        effect = global_mouvement!(f_mouv, y_tmp[3], k, l, inst.ratio,  y_tmp[4], inst.col_avant, inst.Hprio, obj, inst.pbl, f_rand)
        compteurMvt!(f_mouv, nb,nb_effectiv,effect)
    end
end

function convert_genetic_PLS(y::Array{T,1}) where T
    return (y[1], y[3], y[2])
end
