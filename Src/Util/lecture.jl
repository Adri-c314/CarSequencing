# Fichier contenant toutes les methodes de lecture/ecriture
# @author Corentin Pelhâtre
# @date 22/10/2019
# @version 2

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



# Fonction qui permet de verifier la presence d'un dossier
# @param path : l'adresse du dossier
# @param dossier : le nom du dossier
# @param std : L'adresse de sortie des std
function verifDossier(path::String, dossier::String, std::String)
    # Ls du path :
    run(pipeline(`ls $path`, stdout=pipeline(`sort`, string(std, "stdout"))))

    # Lecture du fichier stdout :
    flux=open(string(std, "stdout"))
    stdout = readlines(flux)
    close(flux)

    # verification de la sortie :
    return length(findall(x -> (x == dossier), stdout)) > 0
end
