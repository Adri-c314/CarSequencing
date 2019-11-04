# Fonction d'evaluation du mouvement de reflection
# @param sequence_courante : la sequence ou instance courante
# @param score_courrant : la valeur du score sur les differents obj
# @param k : l'indice de k
# @param l : l'indice de l
# @return ::Bool : true si le mouvement est worth
# @modify score_courrant : Modifie le score courant si accepter
function reflection(sequence_courante::Array{Array{Int32,1},1}, k::Int32, l::Int32, score_courrant::Array{Int32,1},ratio_option::Array{Array{Int32,1}},tab_violation::Array{Array{Int32,1}},Hprio::Int32,obj::Array{Int32,1},pbl::Int32,rand_mov::Symbol)

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
        #if !cond
        #    return
        #end
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
