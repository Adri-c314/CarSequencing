# Fichier tous les algorithms gloutons et leurs foncions associées
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 3




# Fonction qui fait appelle à la bonne fonction de mouvement
# @param LSfoo!::Function : LSfoo! doit etre une des fonctions de recherche locale (swap!, fw_insertion!, bw_insertion!, reflection!, permutation!). Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
# @param sequence_courrante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @param sz : le nombre de vehicules
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
#sequence_meilleure,k,l,score_meilleur,ratio_option,tab_violation,Hprio,obj,pbl,f_rand
function global_mouvement!(LSfoo!::Function, sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   nothing
end






# =====================================================================
# =========              forward insertion              ===============
# =====================================================================

# Fonction principale du mouvement de forward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
function fw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   #TODO : Realise la fw_insertion tranquille pepere sans te soucier de rien
   nothing
end





# =====================================================================
# ====================           reflection         ===================
# =====================================================================

# Fonction principale du mouvement de reflection
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
# @modify score_courrant : ?????
function reflection!(sequence_courante::Array{Array{Int32,1},1}, k::Int32, l::Int32, score_courrant::Array{Int32,1},ratio_option::Array{Array{Int32,1}},tab_violation::Array{Array{Int32,1}},Hprio::Int32,obj::Array{Int32,1},pbl::Int32,rand_mov::Symbol)
    sz = size(sequence_courante)[1]
    cond = true
    tmp_color=0
    tmp_Hprio=0
    tmp_Lprio=0

    for o in obj
        if     o==1 && (rand_mov!=:border_block_two! ||rand_mov!=:same_color!||rand_mov!=:violation_same_color!)
            tmp_color = eval_couleur_reflection(sequence_courante,pbl,k,l)
            cond = tmp_color<=0
            if tmp_color<0
                break
            end
        elseif o==2
            tmp_Hprio = eval_Hprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Hprio <=0
            if tmp_Hprio<0
                break
            end
        elseif o==3
            tmp_Lprio = eval_Lprio_reflection(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
            if tmp_Lprio<0
                break
            end
        end
    end
    tmp = [i for i in (k):(l)]
    tmp =reverse(tmp)
    for i in 1:sz
        println(tab_violation[i])
    end
    for i in 1:sz
        println(sequence_courante[i])
    end

    aa , b =evaluation_init(sequence_courante,ratio_option,Hprio)
    update_tab_violation_reflection(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l),sequence_courante[tmp])
    a  ,b=evaluation_init(sequence_courante,ratio_option,Hprio)
    update_col_and_pbl_reflection(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    for i in 1:sz
        println(tab_violation[i])
    end
    for i in 1:sz
        println(sequence_courante[i])
    end
    println(tmp_Hprio)
    println(aa)
    println(a)
    if a[1]>aa[1]||a[2]>aa[2]+10
        println(tmp_Hprio)
        println(aa)
        println(a)
        println(tadarone)
        return tadarone
    end
    nothing # Pas de return pour eviter les copies de memoire.
end



function update_tab_violation_reflection(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation::Array{Array{Int32,1},1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0
    for i in 1:Hprio
        for j in 0:l-k-1
            if sequence_courante[k+j][i+2]!=sequence_courante[max(1,l-j)][i+2]
                if sequence_courante[k+j][i+2]==1
                    tab_violation[l-j+ratio_option[i][2]-1][i]+=1
                    tab_violation[k+j][i]-=1
                    println("j  ",j ," -1")
                elseif sequence_courante[max(1,l-j)][i+2]==1
                    tab_violation[l-j+ratio_option[i][2]-1][i]-=1
                    tab_violation[k+j][i]+=1
                    println("j  ",j ,"+1"," pos : ",k+j)

                end
            end
        end
    end

    return tmp_viol
end


function eval_couleur_reflection(sequence_courante::Array{Array{Int32,1},1},pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0
    println(k)
    println(l)
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return tmp_color
    end
    if l-k>1


        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                if (sequence_courante[l+1][szcar-1]-l+1)+(sequence_courante[k][szcar-1]-k)>pbl
                    return 1
                end
                tmp_color-=1
            end

        end

        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                if (k-sequence_courante[k-1][szcar-2])+(l-sequence_courante[l][szcar-2])>pbl
                    return 1
                end
                tmp_color-=1
            end
        end
        if l<sz && sequence_courante[l][2]==sequence_courante[l+1][2]
            tmp_color+=1
        end
        if k>1 && sequence_courante[k][2]==sequence_courante[k-1][2]
            tmp_color+=1
        end

    else
        if l<sz
            if sequence_courante[k][2]==sequence_courante[l+1][2]
                if sequence_courante[l+1][szcar-1]-sequence_courante[l+1][szcar-2]==pbl
                    return 1
                end
                tmp_color-=1
            end
        end

        if k>1
            if sequence_courante[l][2]==sequence_courante[k-1][2]
                if sequence_courante[k-1][szcar-1]-sequence_courante[k-1][szcar-2]==pbl
                    return 1
                end
                tmp_color-=1
            end
        end

        if l<sz && sequence_courante[l][2]==sequence_courante[l+1][2]
            tmp_color+=1
        end
        if k>1 && sequence_courante[k][2]==sequence_courante[k-1][2]
            tmp_color+=1
        end



    end

    return tmp_color
end


function update_col_and_pbl_reflection(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation::Array{Array{Int32,1},1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    col = sequence_courante[k][2]
    debk = k
    if col==sequence_courante[debk][2]
        while debk>=1 && col==sequence_courante[debk][2]
            debk-=1
        end
        debk+=1
    end
    debseq = debk

    col = sequence_courante[l][2]
    finl = l
    if col==sequence_courante[finl][2]
        while finl<= sz col==sequence_courante[finl][2]
            finl+=1
        end
        finl-=1
    end
    finseq = min(sz,finl)
    deb = debseq
    col=sequence_courante[debseq][2]
    for i in debseq:finseq
        if sequence_courante[i][2]!= col
            col=sequence_courante[i][2]
            deb = i
        end
        sequence_courante[i][szcar-2]=deb
    end

    tmpi = finseq
    fin = finseq
    col=sequence_courante[finseq][2]
    for i in debseq:finseq
        if tmpi>=1 &&sequence_courante[tmpi][2]!= col
            col=sequence_courante[tmpi][2]
            fin = tmpi
        end

        sequence_courante[tmpi][szcar-1]=fin
        tmpi-=1
    end
end

##
# en gros si on a des gros l-k et des petit Qi bah on regarde que sur les bords c'est plus intelligent mais chiant et bon j'attend reflection mdrrrrrrrrr
#
#
function eval_Hprio_reflection(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation1::Array{Array{Int32,1},1},Hprio::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0
    tab_violation = deepcopy(tab_violation1)
    for i in 1:Hprio
        for j in 0:ratio_option[i][2]-1
            if k+j<=sz && l-j>= 1 && sequence_courante[max(sz,k+j)][i+2]!=sequence_courante[max(1,l-j)][i+2]
                if sequence_courante[k+j][i+2]==1
                    tab_violation[k+j][i]-=1
                    if(tab_violation[k+j][i]>=0)
                        tmp_viol-=1
                    end
                elseif sequence_courante[max(1,l-j)][i+2]==1 &&  l-j+ratio_option[i][2]-1 <= sz
                    tab_violation[l-j+ratio_option[i][2]-1][i]+=1
                    if(tab_violation[l-j+ratio_option[i][2]-1][i]>0)
                        tmp_viol+=1
                    end
                end
            end

        end
    end

    return tmp_viol
end


##
# evalue la difference de EP si on effectu le swap k,l
#
#
# @return Int : le nombre de ENP de difference
function eval_Lprio_reflection(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation1::Array{Array{Int32,1},1},Hprio::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    kk=k
    tmp_viol=0
    tab_violation = deepcopy(tab_violation1)
    for i in Hprio+1:size(ratio_option)[1]
        k = l
        for l in kk:l
            if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[k][i+2]==1
                    for j in k:min(sz,k+ratio_option[i][2]-1)
                        tab_violation[j][i]-=1
                        if(tab_violation[j][i]>=0)
                            tmp_viol-=1
                        end
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in k:min(sz,k+ratio_option[i][2]-1)
                        tab_violation[j][i]+=1
                        if(tab_violation[j][i]>0)
                            tmp_viol+=1
                        end
                    end
                end
            end
            k-=1
        end
    end
    k=kk

    return tmp_viol
end


function evaluation_reflection(instance::Array{Array{Int32,1},1},ratio::Array{Array{Int32,1},1},Hprio::Int,tab_violation::Array{Array{Int32,1},1})
    col = instance[1][2]
    sz =size(instance)[1]
    nbcol = 0
    Hpriofail=0
    Lpriofail=0
    maxprio =0
    ra = [-ratio[i][1] for i in 1:size(ratio)[1]]
    tab_violation = [copy(ra) for i in 1:size(instance)[1]]
    evalrat = [zeros(ratio[i][2]) for i in 1:size(ratio)[1]]
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
                if tmpi>=ratio[tmprio][2] &&mod(tmpi-i,ratio[tmprio][2])==0
                    tab_violation[tmpi][tmprio]+=eval[i]
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

    return [nbcol,Hpriofail,Lpriofail]
end




# =====================================================================
# ====================          swap                ===================
# =====================================================================

# Fonction principale du mouvement de swap
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param obj : tab des fonction obj
# @param pbl : paint batch limit
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : la sequence courante est mise à jour
function swap!(sequence_courante::Array{Array{Int,1},1}, k::Int, l::Int, ratio_option::Array{Array{Int,1}}, tab_violation::Array{Array{Int,1}}, Hprio::Int, obj::Array{Int,1}, pbl::Int, rand_mov::Symbol)
    # Realisation du benefice ou non du mvt
    cond = true
    tmp_color=0
    for o in obj
        if o==1 && (rand_mov!=:border_block_two! ||rand_mov!=:same_color!||rand_mov!=:violation_same_color!)
            tmp_color = eval_couleur_swap(sequence_courante, pbl, k, l)
            cond = tmp_color<=0
            if tmp_color<0
                break
            end
        elseif o==2
            tmp_Hprio = eval_Hprio_swap(sequence_courante, ratio_option, tab_violation, Hprio, k, l)
            cond = tmp_Hprio <=0
            if tmp_Hprio<0
                break
            end
        elseif o==3
            tmp_Lprio = eval_Lprio_swap(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
            if tmp_Lprio<0
                break
            end
        end
        # Si ça n'ameliore pas alors on fait rien
        if !cond
            return
        end
    end

    # Sinon on realise le mouvement de swap :
    tmp=sequence_courante[k]
    sequence_courante[k]=sequence_courante[l]
    sequence_courante[l]=tmp

    # Mise à jour du tableau de violation et pbl :
    update_tab_violation_and_pbl_swap!(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)

    nothing # Pas de return pour eviter les copies de memoire.
end



# Fontion qui evalue la difference de RAF si on effectu le swap k,l
# @param sequence_courrante : la sequence ou instance courante
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Bool : si c'est autorisé comme changement
function eval_couleur_swap(sequence_courante::Array{Array{Int64,1},1}, pbl::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return tmp_color
    end

    if sequence_courante[k][2]==sequence_courante[l-1][2]
        if sequence_courante[l-1][szcar-1]-sequence_courante[l-1][szcar-2]==pbl
            return 1
        end
        tmp_color-=1
    end

    if l<sz
        if sequence_courante[k][2]==sequence_courante[l+1][2]
            if sequence_courante[l+1][szcar-1]-sequence_courante[l+1][szcar-2]==pbl
                return 1
            end
            tmp_color-=1
        end

        if sequence_courante[k][2]==sequence_courante[l+1][2]&& sequence_courante[k][2]==sequence_courante[l-1][2]
            if sequence_courante[l+1][szcar-1]-sequence_courante[l-1][szcar-2]>pbl
                return 1
            end
        end
    end

    if sequence_courante[l][2]==sequence_courante[k+1][2]
        if sequence_courante[k+1][szcar-1]-sequence_courante[k+1][szcar-2]==pbl
            return 1
        end
        tmp_color-=1
    end

    if k>1
        if sequence_courante[l][2]==sequence_courante[k-1][2]
            if sequence_courante[k-1][szcar-1]-sequence_courante[k-1][szcar-2]==pbl
                return 1
            end
            tmp_color-=1
        end

        if sequence_courante[l][2]==sequence_courante[k+1][2]&& sequence_courante[l][2]==sequence_courante[k-1][2]
            if sequence_courante[k+1][szcar-1]-sequence_courante[k-1][szcar-2]>pbl
                return 1
            end
        end
    end

    if sequence_courante[l][2]==sequence_courante[l-1][2]
        tmp_color+=1
    end
    if l<sz && sequence_courante[l][2]==sequence_courante[l+1][2]
        tmp_color+=1
    end
    if sequence_courante[k][2]==sequence_courante[k+1][2]
        tmp_color+=1
    end
    if k>1 && sequence_courante[k][2]==sequence_courante[k-1][2]
        tmp_color+=1
    end

    return tmp_color
end



# Fonction qui evalue la difference de EP si on effectu le swap k,l
# @param sequence_courrante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @param rand_mov : le Symbol de la fonction utilisé pour trouvé k et l
# @return Int : le nombre de EP de difference
function eval_Hprio_swap(sequence_courante::Array{Array{Int64,1},1}, ratio_option::Array{Array{Int64,1},1}, tab_violation::Array{Array{Int64,1},1}, Hprio::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:Hprio
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    #println(tmp_viol)
    return tmp_viol
end



# Fonction qui reevalue les color et le tab_violation de la new sol
# @param sequence_courrante : la sequence ou instance courante
# @param ratio_option : liste de ratio (premiere colonne p et seconde q)
# @param tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param pbl : paint batch limit
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @modify tab_violation : les tableau sont maj
# @modify sequence_courrante : modifie les fenetre dans la sequence
function update_tab_violation_and_pbl_swap!(sequence_courante::Array{Array{Int64,1},1}, ratio_option::Array{Array{Int64,1},1}, tab_violation,Hprio::Int64, pbl::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]

    ## update des color k
    tmpkdeb=k
    tmpkfin=k
    while tmpkdeb>1 &&(sequence_courante[k][2]==sequence_courante[tmpkdeb][2])
        tmpkdeb-=1
    end
    tmpkdeb+=1
    debk = tmpkdeb


    while tmpkfin<sz &&(sequence_courante[k][2]==sequence_courante[tmpkfin][2])
        tmpkfin+=1
    end
    tmpkfin-=1
    fink = tmpkfin
    while tmpkfin>debk
        sequence_courante[tmpkfin][szcar-2]= tmpkdeb
        sequence_courante[tmpkfin][szcar-1]= fink
        tmpkfin-=1
    end


    ## update des color l
    tmpldeb=l
    tmplfin=l

    while tmpldeb>1 &&(sequence_courante[l][2]==sequence_courante[tmpldeb][2])
        tmpldeb-=1
    end
    tmpldeb+=1
    debl = tmpldeb

    while tmplfin<sz &&(sequence_courante[l][2]==sequence_courante[tmplfin][2])
        tmplfin+=1
    end
    tmplfin-=1
    finl = tmplfin
    while tmplfin>debl
        sequence_courante[tmplfin][szcar-2]= tmpldeb
        sequence_courante[tmplfin][szcar-1]= finl
        tmplfin-=1
    end

    ## update du tab_violation
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    tab_violation[j][i]+=1
                end
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    tab_violation[j][i]-=1
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    tab_violation[j][i]+=1
                end
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    tab_violation[j][i]-=1
                end
            end
        end
    end
end



# Fonction qui evalue la difference de EP si on effectu le swap k,l
# @param sequence_courrante : la sequence ou instance courante
# ration_option : liste de ratio (premiere colonne p et seconde q)
# tab_violation : tab_violation[i, j] = est le nombre de fois que l'option j apparait dans la fenetre finissant à i
# @param Hprio : le tableau des H
# @param k : l'indice de k (avec k<l)
# @param l : l'indice de l (avec k<l)
# @return Int : le nombre de ENP de difference
function eval_Lprio_swap(sequence_courante::Array{Array{Int64,1},1}, ratio_option::Array{Array{Int64,1},1}, tab_violation::Array{Array{Int64,1},1}, Hprio::Int, k::Int, l::Int)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in Hprio+1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(sz,k+ratio_option[i][2]-1)
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    return tmp_viol
end





# =====================================================================
# =============              backward insertion       =================
# =====================================================================

# Fonction principale du mouvement de backward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param k : l'indice de k
# @param l : l'indice de l
# @return nothing : Pas de return pour eviter les copies de memoire.
# @modify sequence_courante : ?????
function bw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, k::UInt64, l::UInt64)
   #TODO : Realise la bw_insertion tranquille pepere sans te soucier de rien
   nothing # Pas de return pour eviter les copies de memoire.
end



# Fonction d'evaluation du mouvement de backward insertion
# @param sequence_courrante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function test_bw_insertion!(sequence_courrante::Array{Array{Int64,1},1}, score_courrant::Array{Int64,1}, k::UInt64, l::UInt64)
   #TODO : L'evaluer et si elle est meilleure (a 100*(R-1) % pres), garder les modifs, sinon les retirer de sequence_courrante.
   return true
end





# =====================================================================
# =============                Random shuffle         =================
# =====================================================================




function shuffle(sequence_courante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1},ratio_option::Array{Array{Int32,1},1},tab_violation::Array{Array{Int32,1},1},Hprio::Int,obj::Array{Int32,1},pbl::Int)
    sz = size(sequence_courante)[1]
    if pbl >10
        l = rand(2:5,1)[1]
    else
        l = rand(10:pbl,1)[1]
    end

    k = rand(1:sz-l,1)[1]

    ## shuffle un array ça existe 100%
    rng = MersenneTwister(3);
    seq =randperm(rng,l)

    for i in 1:l
        seq[i]+=k-1
    end

    cond_no = true
    cond_ui =false
    #aa , b =evaluation_init(sequence_courante,ratio_option,Hprio)
    tmp_Hprio = 0
    tmp_Lprio =0
    for o in obj

        if o==1
            cond_no = eval_couleur_shuffle(sequence_courante,seq,pbl,k,l)
        elseif o==2
            tmp_Hprio = eval_Hprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)
            cond_no = tmp_Hprio<=0
            cond_ui =tmp_Hprio<0
        elseif o==3
            tmp_Lprio = eval_Lprio_shuffle(sequence_courante,ratio_option,tab_violation,Hprio,k,l,seq)
            cond_no = tmp_Lprio<=0
            cond_ui =tmp_Lprio<0
        end
        if !cond_no
            return
        end
        if(cond_ui)
            break
        end

    end

    update_tab_violation_shuffle(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l+k-1),sequence_courante[seq])
    update_col_and_pbl(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
    return
end

function update_tab_violation(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation::Array{Array{Int32,1},1},sequence::Array{Int32,1},Hprio::Int,pbl::Int,k::Int,l::Int)
    ## update du tab_violation
    sz = size(sequence_courante)[1]
    tmp_viol=0
    l = size(sequence)[1]
    for i in 1:Hprio
        kk = k
        for l in sequence
            if sequence_courante[kk][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[kk][i+2]==1
                    for j in max(kk,ratio_option[i][2]):min(sz,kk+ratio_option[i][2]-1)
                        tab_violation[j][i]-=1
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in max(kk,ratio_option[i][2]):min(sz,kk+ratio_option[i][2]-1)
                        tab_violation[j][i]+=1
                    end
                end
            end
            kk+=1
        end
    end
end


function eval_Hprio_shuffle(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation1::Array{Array{Int32,1},1},Hprio::Int,k::Int,l::Int,sequence)
    sz = size(sequence_courante)[1]
    kk=k
    tmp_viol=0
    tab_violation = deepcopy(tab_violation1)
    l = size(sequence)[1]
    for i in 1:Hprio
        k = kk
        for l in sequence
            if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[k][i+2]==1
                    for j in max(k,ratio_option[i][2]):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[j][i]-=1
                        if(tab_violation[j][i]>=0)
                            tmp_viol-=1
                        end
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in max(k,ratio_option[i][2]):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[j][i]+=1
                        if(tab_violation[j][i]>0)
                            tmp_viol+=1
                        end
                    end
                end
            end
            k+=1
        end
    end
    k=kk

    return tmp_viol
end


function eval_Lprio_shuffle(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation1::Array{Array{Int32,1},1},Hprio::Int,k::Int,l::Int,sequence)
    sz = size(sequence_courante)[1]
    kk=k
    tmp_viol=0
    tab_violation = deepcopy(tab_violation1)
    l = size(sequence)[1]
    for i in Hprio+1:size(ratio_option)[1]
        k = kk
        for l in sequence
            if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
                if sequence_courante[k][i+2]==1
                    for j in max(k,ratio_option[i][2]):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[j][i]-=1
                        if(tab_violation[j][i]>=0)
                            tmp_viol-=1
                        end
                    end
                elseif sequence_courante[l][i+2]==1
                    for j in max(k,ratio_option[i][2]):min(sz,k+ratio_option[i][2]-1)
                        tab_violation[j][i]+=1
                        if(tab_violation[j][i]>0)
                            tmp_viol+=1
                        end
                    end
                end
            end
            k+=1
        end
    end
    k=kk

    return tmp_viol
end


function eval_couleur_shuffle(sequence_courrante::Array{Array{Int32,1},1},sequence::Array{Int32,1},pbl::Int,k::Int,l::Int)

    szcar = size(sequence_courrante[1])[1]
    sz = size(sequence_courrante)[1]

    deb = 1
    deb = max(1,k-1)
    fin = sz
    fin = min(k+l+1,sz)
    col = sequence_courrante[deb][2]
    nbcol=0
    tmpi = sequence_courrante[deb][szcar-1]
    while tmpi<=fin && tmpi<sz
        tmpi = sequence_courrante[tmpi+1][szcar-1]
        nbcol+=1
    end


    col = sequence_courrante[max(1,k-1)][2]

    tmpnbcol = 0
    tmp_pbl=1
    for i in k:k+l-1
        if sequence_courrante[sequence[i-k+1]][2]!= col
            tmpnbcol+=1
            col=sequence_courrante[sequence[i-k+1]][2]
            tmp_pbl=1
        end
        tmp_pbl+=1
        if(tmpnbcol>nbcol)||tmp_pbl>pbl
            return false
        end
    end
    if sequence_courrante[k+l][2]!= col
        tmpnbcol+=1
    end
    if(tmpnbcol>nbcol)||tmp_pbl>pbl
        return false
    else
        tmp_pbl+=1
    end

    return true
end
