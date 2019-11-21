# Fichier contenant toutes les fonction associées au crossover entre plusieurs sequence
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 21/11/2019
# @version 1



# Fonction qui realise le crossover entre deux sequences
# @param sol1 : La premiere sequence selectionnée
# @param tab_violation1 : le tableau de violation de la premiere sequence
# @param sol2 : La seconde sequence selectionnée
# @param tab_violation2 : le tableau de violation de la seconde sequence
# @return ::Array{Array{Int,1},1} : la nouvelle sequence créer à partir des deux autres
# @return ::Array{Array{Int,1},1} : le tableau de violation associé à cette sequence
function crossover(sol1::Array{Array{Int,1},1}, tab_violation1::Array{Array{Int,1},1}, sol2::Array{Array{Int,1},1}, tab_violation2::Array{Array{Int,1},1})
    # TODO : realiser un crossover entre les deux solutions
    sol3 = sol1 # Pour pas que sa plante mais ça pu !
    tab_violation3 = tab_violation2
    return sol3, tab_violation3
end
