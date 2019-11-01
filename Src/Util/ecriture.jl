# Fonction qui permet d'ecrire le text passé en paramètre dans le fichier passé en paramètre
# @param text le texte à ecrire
# @param file le fichier (ou path/fichier) dans lequel ecrire
function ecriture(text::String, file::String)
    run(pipeline(`echo -e $text`, stdout=file))
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
