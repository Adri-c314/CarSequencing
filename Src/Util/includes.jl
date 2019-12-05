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
include("../Metaheuristique/VFLS_ini.jl")
include("../Metaheuristique/mouvement_2_Le_Retour.jl")

include("../Metaheuristique/Sommet.jl")
include("../Metaheuristique/NDtree.jl")

# Les fichiers liés à l'algorithm genetic
include("../genetic/crossover.jl")
include("../genetic/generate.jl")
include("../genetic/genetic.jl")
include("../genetic/mutation.jl")
include("../genetic/majpop.jl")

include("../Metaheuristique/IniNDtree.jl")
include("../Metaheuristique/mouvement_3_is_back.jl")
