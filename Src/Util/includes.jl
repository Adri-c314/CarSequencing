# Les fichiers utils
include("./ecriture.jl")
include("./lecture.jl")
include("./fonction_rand.jl")

# Les fichiers liés à la méta de base
include("../Metaheuristique/choisir_klLS.jl")
include("../Metaheuristique/greedy.jl")
include("../Metaheuristique/init.jl")
include("../Metaheuristique/mouvement.jl")
include("../Metaheuristique/VFLS.jl")

# Les fichiers liés à l'algorithm genetic
include("../genetic/crossover.jl")
include("../genetic/generate.jl")
include("../genetic/genetic.jl")
include("../genetic/mutation.jl")
