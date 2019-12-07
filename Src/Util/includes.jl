# Les fichiers utils
include("./ecriture.jl")
include("./lecture.jl")
include("./fonction_rand.jl")
include("./instance.jl")

# Les fichiers liés à la méta de base
include("../Metaheuristique/choisir_klLS.jl")
include("../Metaheuristique/greedy.jl")
include("../Metaheuristique/init.jl")
include("../Metaheuristique/mouvement.jl")
include("../Metaheuristique/VFLS.jl")
include("../Metaheuristique/pop_elites.jl")
include("../Metaheuristique/mouvement_2_Le_Retour.jl")
include("../Metaheuristique/IniNDtree.jl")
include("../Metaheuristique/mouvement_3_is_back.jl")

# Les fichiers liés à l'algorithm genetic
include("../genetic/crossover.jl")
include("../genetic/generate.jl")
include("../genetic/genetic.jl")
include("../genetic/mutation.jl")
include("../genetic/majpop.jl")

# Les fichiers lié à la PLS et tous ce qui touche au KDTree
include("../PLS&Tree/Pareto_Local_Search.jl")
include("../PLS&Tree/Sommet.jl")
include("../PLS&Tree/NDtree.jl")
