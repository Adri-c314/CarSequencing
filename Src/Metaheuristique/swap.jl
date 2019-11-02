# Squelette de la fonction de swap, par Xavier



## k et l avec k<l
function swap!(sequence_courante::Array{Array{Int32,1},1}, k::Int32, l::Int32, score_courrant::Array{Int32,1},ratio_option::Array{Array{Int32,1}},tab_violation::Array{Array{Int32,1}},Hprio::Int32,obj::Array{Int32,1},pbl::Int32)

    cond = true
    for o in obj
        if     o==1
            cond = eval_couleur(sequence_courante,pbl,k,l)
        elseif o==2
            tmp_Hprio = eval_Hprio(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Hprio <=0
        elseif o==3
            tmp_Lprio = eval_Lprio(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
            cond = tmp_Lprio <=0
        end
        if !cond
            return
        end
    end
    aa , bb =evaluation_init(sequence_courante,ratio_option,Hprio)
    println(aa)

    tmp=sequence_courante[k]
    sequence_courante[k]=sequence_courante[l]
    sequence_courante[l]=tmp
    update_tab_violation_and_pbl(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
    a , b =evaluation_init(sequence_courante,ratio_option,Hprio)

    println(a)


    nothing # Pas de return pour eviter les copies de memoire.
end


##
# evalue la difference de RAF si on effectu le swap k,l
#
# @return Bool : si c'est autorisé comme changement
function eval_couleur(sequence_courante,pbl,k,l)
    sz = size(sequence_courante)[1]
    szcar =size(sequence_courante[1])[1]
    tmp_color=0
    ## on test le new pbl c'est important
    if sequence_courante[k][2]==sequence_courante[l][2]
        return true
    end

    if sequence_courante[k][2]==sequence_courante[l-1][2]
        if sequence_courante[l-1][szcar-1]-sequence_courante[l-1][szcar-2]==pbl
            return false
        end
        tmp_color-=1
    end

    if l<sz
        if sequence_courante[k][2]==sequence_courante[l+1][2]
            if sequence_courante[l+1][szcar-1]-sequence_courante[l+1][szcar-2]==pbl
                return false
            end
            tmp_color-=1
        end

        if sequence_courante[k][2]==sequence_courante[l+1][2]&& sequence_courante[k][2]==sequence_courante[l-1][2]
            if sequence_courante[l+1][szcar-1]-sequence_courante[l-1][szcar-2]>pbl
                return false
            end
        end
    end

    if sequence_courante[l][2]==sequence_courante[k+1][2]
        if sequence_courante[k+1][szcar-1]-sequence_courante[k+1][szcar-2]==pbl
            return false
        end
        tmp_color-=1
    end

    if k>1
        if sequence_courante[l][2]==sequence_courante[k-1][2]
            if sequence_courante[k-1][szcar-1]-sequence_courante[k-1][szcar-2]==pbl
                return false
            end
            tmp_color-=1
        end

        if sequence_courante[l][2]==sequence_courante[k+1][2]&& sequence_courante[l][2]==sequence_courante[k-1][2]
            if sequence_courante[k+1][szcar-1]-sequence_courante[k-1][szcar-2]>pbl
                return false
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

    return tmp_color<=0
end


##
#On reevalue les color et le tab_violation de la new sol
#
#
function update_tab_violation_and_pbl(sequence_courante,ratio_option,tab_violation,Hprio,pbl,k,l)
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
                for j in k:min(sz,k+ratio_option[i][2])
                    tab_violation[j][i]+=1
                end
                for j in l:min(sz,l+ratio_option[i][2])
                    tab_violation[j][i]-=1
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2])
                    tab_violation[j][i]+=1
                end
                for j in k:min(sz,k+ratio_option[i][2])
                    tab_violation[j][i]-=1
                end
            end
        end
    end

end

##
# evalue la difference de EP si on effectu le swap k,l
#
# @return Int : le nombre de EP de difference
function eval_Hprio(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in 1:Hprio
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2])
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in l:min(sz,l+ratio_option[i][2])
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2])
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(sz,k+ratio_option[i][2])
                    if(tab_violation[j][i]>=0)
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
function eval_Lprio(sequence_courante,ratio_option,tab_violation,Hprio,k,l)
    sz = size(sequence_courante)[1]
    tmp_viol=0 ##sorry pour ce nom xD
    for i in Hprio+1:size(ratio_option)[1]
        if sequence_courante[k][i+2]!=sequence_courante[l][i+2]
            if sequence_courante[k][i+2]==1
                for j in k:min(sz,k+ratio_option[i][2])
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in l:min(sz,l+ratio_option[i][2])
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            elseif sequence_courante[l][i+2]==1
                for j in l:min(sz,l+ratio_option[i][2])
                    if(tab_violation[j][i]>0)
                        tmp_viol-=1
                    end
                end
                for j in k:min(sz,k+ratio_option[i][2])
                    if(tab_violation[j][i]>=0)
                        tmp_viol+=1
                    end
                end
            end
        end
    end
    return tmp_viol
end
