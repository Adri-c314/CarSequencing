# Squelette de la fonction de swap, par Xavier

function swap!(sequence_courrante::Array{Array{Int32,1},1}, k::Int32, l::Int32, score_courrant::Array{Int32,1},prio::Array{Array{Int32,1}},Hprio::Int32,obj::Array{Int32,1},pbl::Int32)
    score_init=[0,0,0]
    tmp_violation=Int32(0)
    #Evaluation initiale
    for i in 1:length(prio)
        tmp_val_courrante=sequence_courrante[max(k-prio[i][2],1)][i+2]
        for j in max(k+1-prio[i][2],2):k
            if sequence_courrante[j][i+2] != tmp_val_courrante
                tmp_violation+=1
            end
        end
        if i>Hprio
            score_init[3]+=tmp_violation
        else
            score_init[2]+=tmp_violation
        end
        tmp_violation=0
    end

    tmp_val_courrante=sequence_courrante[max(k-pbl,1)][2]
    for j in  max(k+1-pbl,2):k
        if sequence_courrante[j][2] != tmp_val_courrante
            tmp_violation+=1
        end
    end
    score_init[1]+=tmp_violation
    #On effectu le changement

    tmp=sequence_courrante[k]
    sequence_courrante[k]=sequence_courrante[l]
    sequence_courrante[l]=tmp

    #Deuxième eval
    score_final=[0,0,0]
    tmp_violation=0
    for i in 1:length(prio)
        tmp_val_courrante=sequence_courrante[max(k-prio[i][2],1)][i+2]
        for j in  max(k+1-prio[i][2],2):k
            if sequence_courrante[j][i+2] != tmp_val_courrante
                tmp_violation+=1
            end
        end
        if i>Hprio
            score_final[3]+=tmp_violation
        else
            score_final[2]+=tmp_violation
        end
        tmp_violation=0
    end

    tmp_val_courrante=sequence_courrante[max(k-pbl,1)][2]
    for j in max(k+1-pbl,2):k
        if sequence_courrante[j][2] != tmp_val_courrante
            tmp_violation+=1
        end
    end
    score_final[1]+=tmp_violation
    #On accepte ou non le swap
    if score_final[obj[1]]>1.05*score_init[obj[1]]
        tmp=sequence_courrante[k]
        sequence_courrante[k]=sequence_courrante[l]
        sequence_courrante[l]=sequence_courrante[tmp]
    end
    nothing # Pas de return pour eviter les copies de memoire.
end
