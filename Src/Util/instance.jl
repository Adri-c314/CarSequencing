struct Instance
    sequence_j_avant::Array{Array{Int,1},1}     # : la sequence apres toute l'initialisation
    col_avant::Tuple{Int32,Int32}               # : La couleur de la veille
    ratio::Array{Array{Int,1},1}                # : ratio_option le tableau des options
    Hprio::Int                                  # : Hprio le nombre d'options prioritaires
    obj::Array{Int,1}                           # : le tableau des objectifs
    pbl::Int                                    # : PAINT_BATCH_LIMIT
end

# inst = Instance(sequence_j_avant, col_avant, ratio, Hprio, obj, pbl) Pour creer la structure
# inst.Hprio pour get le Hprio par exemple
