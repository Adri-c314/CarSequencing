# Fichier contenant toutes les fonctions d'ecriture sur disque
# @author Corentin Pelhâtre
# @date 22/10/2019
# @version 3


# Fonction qui permet d'ecrire le text passé en paramètre dans le fichier passé en paramètre
# @param text le texte à ecrire
# @param file le fichier (ou path/fichier) dans lequel ecrire
function ecriture(text::String, file::String)
    open(file, "w") do f
        write(f, text)
    end
end



# Fonction qui gère le path en cross plateforme
# @param path : l'adresse ou l'on veut ecrire
# @param onLinux : variable bool de la plateforme
# @return ::String : le path adapté
function pathOS(path::String, onLinux::Bool)
    if !onLinux
        return replace(path, "/" => "\\")
    end
    return path
end



# Fonction qui ecris en csv la sequence
# @param seq : la sequence
# @return ::String : le csv lié à la sequence
function seqToCSV(sol::Array{Array{Int,1},1})
    return seqPropreToCSV(nettoyageDeLaMort(sol))
end



# Fonction qui ecris en csv un array de score
# @param score : la sequence
# @return ::String : le csv lié à la sequence
function scoreToCSV(score::Array{Array{Int,1},1})
    txt = ""
    for i in 1:size(score)[1]
        txt = string(txt,"[")
        txt = string(txt, score[i][1],",",score[i][2],",",score[i][3])
        txt = string(txt,"];")
    end
    return txt
end



# Fonction qui permet de sortir la sequence à partir du tableau de solution
# @param sol : la solution à etudier
# @return ::Array{Int, 1} : la sequence nettoyer
function nettoyageDeLaMort(sol::Array{Array{Int,1},1})
    tmp = Array{Int,1}()
    for i in 1:length(sol)
        push!(tmp, sol[i][length(sol[i])])
    end
    return tmp
end



# Fonction qui ecris en csv la sequence
# @param seq : la sequence ayant subit un nettoyageDeLaMort
# @return ::String : le csv lié à la sequence
function seqPropreToCSV(seq::Array{Int, 1})
    txt = ""
    for i in 1:length(seq)
        txt = string(txt, seq[i], ";")
    end
    return txt
end



# Fonction qui creer le dossier s'il n'est pas existant et renvois le path une fois verifier
# @param path le path vers le dossier dans lequel on veut ecrire
# @param std le path vers les fichiers std
# @return path le path vers le dossier si on peut ecrire dedans, sinon, renvois dans la ram
function pathDossier(path::String, std::String)
    avant=""
    i=1
    while string(path[i]) == "." || string(path[i]) =="/" || string(path[i]) == "~"
        avant = string(path[1:i])
        i = i+1
    end

    i = i + 1
    for j in i:length(path)
        if string(path[j]) == "/"
            if !verifDossier(avant, path[length(avant)+1:(j-1)], std)
                tmp = string(path[1:(j-1)])
                run(pipeline(`mkdir $tmp`, stdout=pipeline(`sort`, string(std, "stdout.txt")), stderr=string(std, "errs.txt")))
            end
            avant = string(path[1:j])
        end
    end

    return path
end
