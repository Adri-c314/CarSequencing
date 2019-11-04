#FORWARD_INSERTION : k < l
#|k|x|y|z|l| -> |l|k|x|y|z|

#verifie si pbl est bien respectée (sans changer la sequence)
#return un booléen
function check_Paint_Limit_fw(sequence_courante::Array{Array{Int64,1},1}, k::Int64, l::Int64, pbl::Int64)
    #les 2 variables là c'est juste pour la lisibilité
    debBlockColor = length(sequence_courante[1])-2
    finBlockColor = length(sequence_courante[1])-1
    #on check pbl au niveau de k
    if k > 1
        if sequence_courante[l][2] == sequence_courante[k-1][2] #-> l s'insere dans un block
            if sequence_courante[k-1][finBlockColor] - sequence_courante[k-1][debBlockColor] +2 > pbl
                return false
            end
        elseif sequence_courante[l][2] == sequence_courante[k][2] #-> l commence un nouveau block
            if sequence_courante[k][finBlockColor] - sequence_courante[k][debBlockColor] +2 > pbl
                return false
            end
        end
    else 
        if sequence_courante[l][2] == sequence_courante[k][2] #-> l commence un nouveau block
            if sequence_courante[k][finBlockColor] - sequence_courante[k][debBlockColor] +2 > pbl
                return false
            end
        end
    end   
    #on check pbl au niveau de l
    if l < length(sequence_courante)
        if sequence_courante[l-1][2] == sequence_courante[l+1][2] #-> ca veut dire que 2 blocks sont fusionnés en l
            if sequence_courante[l+1][finBlockColor] - sequence_courante[l-1][debBlockColor] +2 > pbl
                return false
            end
        end
    end
   
    return true
end




##
# evalue la difference de RAF si on fait le mouvement
#
# @return entier 
function eval_couleur_fw(sequence_courante::Array{Array{Int64,1},1},k::Int,l::Int)
    #nb purges avant le mouvement (juste au niveau de k et l car ya que là que ca change)
    nbPurgesAvant = 0
    #au niveau de k : 
    if k > 1
        if sequence_courante[k][2] != sequence_courante[k-1][2]
            nbPurgesAvant += 1
        end
    end
    if sequence_courante[k][2] != sequence_courante[k+1][2]
        nbPurgesAvant += 1
    end
    #au niveau de l :
    if l < length(sequence_courante)
        if sequence_courante[l][2] != sequence_courante[l+1][2]
            nbPurgesAvant += 1
        end
    end
    if sequence_courante[l][2] != sequence_courante[l-1][2]
        nbPurgesAvant += 1
    end
    
    #nb purges après le mouvement (juste au niveau de k et l car ya que là que ca change)
    nbPurgesApres = 0
    #au niveau de k : 
    if k > 1
        if sequence_courante[l][2] != sequence_courante[k-1][2]
            nbPurgesApres += 1
        end
    end
    if sequence_courante[l][2] != sequence_courante[k+1][2]
        nbPurgesApres += 1
    end
    #au niveau de l :
    if sequence_courante[l-1][2] != sequence_courante[l+1][2]
        nbPurgesApres += 1
    end
    
    return nbPurgesApres-nbPurgesAvant
end




##
# calcul les options en plus/ en moins à la position k et l si on fait le mouvement
#je fais cette fonction car je m'en sers à la fois dans l'évaluation et dans l'update donc ca evite de recalculer
#return : 2 array{float} : 1 array pour k, 1 pour j 
#exemple : delta_k[j] = 1 si le mouvement ajoute l'option j à la position k, -1 si l'option est retirée, 0 si ca fait rien
function delta_Hprio_fw(sequence_courante::Array{Array{Int64,1},1},ratio_option::Array{Array{Int64,1},1},tab_violation::Array{Array{Int64,1},1},Hprio::Int,k::Int,l::Int)
    #on regarde les options prioritaires qu'on a en plus/en moins à la position k
    delta_k = zeros(Hprio) 
    for j in 3:2+Hprio
        if sequence_courante[k][j] > sequence_courante[l][j]
            delta_k[j] = -1
        elseif sequence_courante[k][j] < sequence_courante[l][j]
            delta_k[j] = 1
        end
    end
    
    #on regarde les options prioritaires qu'on a en plus/en moins à la position l
    delta_l = zeros(Hprio) 
    for j in 3:2+Hprio
        if sequence_courante[l][j] > sequence_courante[l-1][j]
            delta_l[j] = -1
        elseif sequence_courante[l][j] < sequence_courante[l-1][j]
            delta_l[j] = 1
        end
    end
    
    return(delta_k, delta_l)
end





# evalue la difference de EP si on effectue le mouvement
#principe de l'algo : on a en param les options ajoutées/retirées aux pos k et l.
#on regarde sur toutes les fenêtres affectées par le mouvement (donc qui contiennt k et l)
#si l'ajout/le retrait d'une option provoque une modif de EP
#@param : delta_k, delta_l : arrays des options en plus/en moins à la position k, respectivement l
#@param : Qmax : le max des dénominateurs des ratios P/Q (pour etre sûr d'avoir toutes les fenêtres)
# @return Int : le nombre de EP de difference
function eval_Hprio_fw(sequence_courante::Array{Array{Int64,1},1},ratio_option::Array{Array{Int64,1},1},tab_violation::Array{Array{Int64,1},1},Hprio::Int,k::Int,l::Int,delta_k::Array{Float64,1},delta_l::Array{Float64,1},Qmax)
    #seules les fenêtres qui contiennent k et l doivent être évaluées
    #pour chaque fenêtre on va donc vérifier si l'ajout/le retrait d'une option engendre une modif de EP
    viol = 0 #coucou
    
    #on évalue d'abord les fenetres qui contiennent k :
    for i in k:max(k+Qmax,length(sequence_courante))
        for j in 3:2+Hprio
            if tab_violation[i][j] == ratio_option[j][1] #si EP est susceptible d'etre modifié
                if delta_k[j-2] == 1
                    viol += 1
                elseif delta_k[j-2] == -1
                    viol = viol-1
                end
            end
        end
    end
    
    #on évalue ensuite les fenetres qui contiennent l :
    for i in l:max(l+Qmax,length(sequence_courante))
        for j in 3:2+Hprio
            if tab_violation[i][j] == ratio_option[j][1] #si EP est susceptible d'etre modifié
                if delta_l[j-2] == 1
                    viol += 1
                elseif delta_l[j-2] == -1
                    viol = viol-1
                end
            end
        end
    end
    
    return viol 
end




#=
#réalise le mouvement en mettant à jour les blocks de couleur, tab_violation, et les valeurs des objectifs (maj les positions ?)
function update_data_fw(sequence_courante::Array{Array{Int64,1},1},ratio_option::Array{Array{Int64,1},1},tab_violation,Hprio::Int64,k::Int,l::Int,delta_k::Array{Float64,1},delta_l::Array{Float64,1})
    #les 2 variables là c'est juste pour la lisibilité
    debBlockColor = length(sequence_courante[1])-2
    finBlockColor = length(sequence_courante[1])-1
    
    #on effectue le mouvement : 
    tmp = sequence_courante[l]
    i= l
    while i >= k+1
        sequence_courante[i] = sequence_courante[i-1]
    i = i-1
    end
    sequence_courante[k] = tmp
    
    #update des blocks de couleur 
    if k > 1
        if sequence_courante[k][2] == sequence_courante[k-1][2]
            if sequence_courante[k][2] == sequence_courante[k+1][2] #cas où k est en plein dans un block de couleur
                for i in sequence_courante[k+1][debBlockColor]:sequence_courante[k+1][finBlockColor]
                    sequence_courante[i][finBlockColor] = sequence_courante[k+1][debBlockColor]+1
                end
            else #cas où k termine un bloc de couleur
                for i in sequence_courante
                end
            end           
        else
        
        end
    end
    
    #=plutot faire comme ca je pense
    toutseul = true
    Si k = k-1 : de deb(k-1) à k : fincol = ...+1 toutseul = false
    si k = k+1 : de k à fin(k+1) : debcol = ...+1 toutseul = false
    si toutseul : deb(k) = fin(k) = k
    =#
end
=#
