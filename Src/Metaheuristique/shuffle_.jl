
using Random
function shuffle_(sequence_courante::Array{Array{Int32,1},1}, score_courrant::Array{Int32,1},ratio_option::Array{Array{Int32,1},1},tab_violation::Array{Array{Int32,1},1},Hprio::Int,obj::Array{Int32,1},pbl::Int)
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

    update_tab_violation(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)
    splice!(sequence_courante,(k):(l+k-1),sequence_courante[seq])
    update_col_and_pbl(sequence_courante,ratio_option,tab_violation,seq,Hprio,pbl,k,l)

    #=a , b =evaluation_init(sequence_courante,ratio_option,Hprio)

    println(aa)
    println(a)
    println(tmp_Hprio)
    if a[1]>aa[1]||a[2]>aa[2]+10
       println(aa)
       println(a)
       #println(tamere)

        #return tamere
    end=#

    return
end

function update_col_and_pbl(sequence_courante::Array{Array{Int32,1},1},ratio_option::Array{Array{Int32,1},1},tab_violation::Array{Array{Int32,1},1},sequence::Array{Int32,1},Hprio::Int,pbl::Int,k::Int,l::Int)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]

    ## update des color
    tmpkdeb=k
    while tmpkdeb>=1 &&(sequence_courante[k][2]==sequence_courante[tmpkdeb][2])
        tmpkdeb-=1
    end
    tmpkdeb+=1
    debk = tmpkdeb


    tmplfin=k+l-1
    while tmplfin<=sz && sequence_courante[k+l-1][2]==sequence_courante[tmplfin][2]
        tmplfin+=1

    end
    tmplfin-=1
    finl = tmplfin

    deb = debk
    col = sequence_courante[deb][2]
    for i in debk:finl
        if sequence_courante[i][2]!= col
            col=sequence_courante[i][2]
            deb = i
        end
        sequence_courante[i][szcar-2]=deb
    end

    fin = finl
    tmpi = fin
    col=sequence_courante[fin][2]
    for i in debk:finl

        if sequence_courante[tmpi][2]!= col
            col=sequence_courante[tmpi][2]
            fin = tmpi
        end
        sequence_courante[tmpi][szcar-1]=fin
        tmpi-=1
    end
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
