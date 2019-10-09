using CSV
using DataFrames
using Query

# Fonction qui permet de lire un fichier csv
# @param path l'adresse du fichier à etudier
# @return (
#           vehicles :: DataFrames.DataFrame
#           optimization_objectives :: DataFrames.DataFrame
#           paint_batch_limit :: DataFrames.DataFrame
#           ratio :: DataFrames.DataFrame
#           )
function lectureCSV(instance::String, ref::String)
    path = string("../../Input/Instances_set_", instance, "/", ref, "/")
    return (CSV.read(string(path, "vehicles.txt")), CSV.read(string(path, "optimization_objectives.txt")), CSV.read(string(path, "paint_batch_limit.txt")), CSV.read(string(path, "ratios.txt")))
end
