struct Instance
    sequence_j_avant::Array{Array{Int,1},1}     # : la sequence apres toute l'initialisation
    ratio::Array{Array{Int,1},1}                # : ratio_option le tableau des options
    Hprio::Int                                  # : Hprio le nombre d'options prioritaires
    obj::Array{Int,1}                           # : le tableau des objectifs
    pbl::Int                                    # : PAINT_BATCH_LIMIT
end

# inst = Instance(sequence_j_avant, ratio, Hprio, obj, pbl) Pour creer la structure
# inst.Hprio pour get le Hprio par exemple
