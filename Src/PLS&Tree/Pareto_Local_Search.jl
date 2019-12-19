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
# @^param nb_efficace_pls : nb de solution no dominé avant que ça passe a une autre solutions
# @param verbose : Si l'on souhaite un affichage console de l'execution
# @param txtoutput : Si l'on souhaite conserver une sortie txt (/!\ cela ne marche que sur linux et mac je penses)
function PLS!(NDtree::Sommet, inst::Instance, temps_max::Float64 = 2800.0, temps_1_moove::Float64 = 10.,nb_efficace_pls::Int = 10, verbose::Bool = true, txtoutput::Bool=true)
    verifPourBug!(NDtree,inst)
    pareto_tmp = get_solutions(NDtree)
    debutall = time()
    ## le PLS
    OBJ = [[1,2,3],[1,3,2],[2,3,1],[2,1,3],[3,2,1],[3,1,2]]
    tmp_sortie = 0
    tmp_sortie_all = 0
    while size(pareto_tmp)[1]>1 && temps_max>time()-debutall

        println(size(pareto_tmp)[1])

        pareto1_tmp = get_solutions(NDtree)
        score_nadir = nadir_global(NDtree)

        tmp_sortie = 0

        for par in pareto_tmp
            if temps_max<time()-debutall
                break
            end
            sequence_meilleure::Array{Array{Int,1},1} = deepcopy(par[1])
            tab_violation::Array{Array{Int,1},1}=  deepcopy(par[3])
            a =  deepcopy(par[2])
            sortie = false
            tmp_sortie =0
            timeOPT1 = [100/3,100/3,100/3]
            @time for Phase in 1:3
                debut = time()
                while temps_1_moove*(timeOPT1[Phase]/100)>time()-debut
                    obj = OBJ[rand(1:6)]
                    timeOPT, opt = phases_init(obj)
                    f_rand, f_mouv = choisir_klLS(sequence_meilleure, opt, obj, Phase)
                    k, l = choose_f_rand(sequence_meilleure, inst.ratio , tab_violation, f_rand, Phase, obj, inst.Hprio)
                    effect = global_mouvement_3!(f_mouv, sequence_meilleure, k, l, inst.ratio, tab_violation , inst.Hprio, obj, inst.pbl, f_rand,a,score_nadir)
                    if effect
                        if maj!(NDtree, (deepcopy(sequence_meilleure),deepcopy(a),deepcopy(tab_violation)))
                            tmp_sortie += 1
                            tmp_sortie_all+=1
                        end
                        if tmp_sortie == nb_efficace_pls
                                sortie = true
                        end
                        sequence_meilleure = deepcopy(par[1])
                        tab_violation=  deepcopy(par[3])
                        a =  deepcopy(par[2])
                    end
                    if sortie
                        break
                    end
                end
                if sortie
                    break
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
    pareto_tmp = get_solutions(NDtree)
    println("FIN")
    nadir = nadir_global(NDtree)
    tab_score = [p[2] for p in pareto_tmp]
    final_score = [tab_score[1]]

    for i in 1:size(tab_score)[1]
        ok = true
        for ii in 1:size(tab_score)[1]
            if i!= ii && tab_score[i][1]>=tab_score[ii][1] && tab_score[i][2]>=tab_score[ii][2] && tab_score[i][3]>=tab_score[ii][3]
                ok = false
            end
            if i<ii && tab_score[i][1]==tab_score[ii][1] && tab_score[i][2]==tab_score[ii][2] && tab_score[i][3]==tab_score[ii][3]
                ok = true
            end
        end
        if ok
            append!(final_score,[tab_score[i]])
        end
    end
    popfirst!(final_score)
    tmpi1=1
    tmpi2=1
    tmpi3=1
    score1=final_score[1][1]
    score2=final_score[1][2]
    score3=final_score[1][3]

    for i in 1:size(final_score)[1]
        if final_score[i][1]<score1
            tmpi1 = i
            score1 = final_score[i][1]
        end
        if final_score[i][2]<score2
            tmpi2 = i
            score2 = final_score[i][2]
        end
        if final_score[i][3]<score3
            tmpi3 = i
            score3 = final_score[i][3]
        end
    end
    println([final_score[tmpi1],final_score[tmpi2],final_score[tmpi3]])
    return final_score, size(final_score)[1], nadir, [final_score[tmpi1],final_score[tmpi2],final_score[tmpi3]]
end


function verifPourBug!(NDtree,inst)
    sol = get_solutions(NDtree)
    rtn = Array{Tuple{Array{Array{Int,1},1}, Array{Int,1}, Array{Array{Int,1},1}},1}()
    for i in sol
        tmp::Array{Array{Int,1},1} = deepcopy(i[1])
        ide3,pblAdmissible,ide1 = majData(tmp, inst.sequence_j_avant, inst.ratio, inst.Hprio, inst.pbl)
        if pblAdmissible
            push!(rtn, (deepcopy(ide1), deepcopy(i[2]), deepcopy(ide3)))
        else
            println("On a une couille dans le poté")
        end
    end

    NDtree = Sommet()
    for i in rtn
        maj!(NDtree, i)
    end
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
        k, l = choose_f_rand(y_tmp[3], inst.ratio, y_tmp[4], f_rand, Phase, obj, inst.inst.Hprio)
        effect = global_mouvement!(f_mouv, y_tmp[3], k, l, inst.ratio,  y_tmp[4], inst.inst.Hprio, obj, inst.inst.pbl, f_rand)
        compteurMvt!(f_mouv, nb,nb_effectiv,effect)
    end
end
